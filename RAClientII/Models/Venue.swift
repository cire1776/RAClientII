//
//  Venue.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/23/22.
//

import GameplayKit

public class Venue: ObservableObject, NSCopying, PhysicalVenue {    
    public typealias ID = String
    
    public var id: String
    @Published var name: String
    @Published var description: String
    
    var orientation = Hexagon.Orientation.point
    
    var region: Hexagon.Region<Geography.TerrainSpecifier>

    var bounds = CGSize(width: 3, height: 3)
    
    @Published var minimap: UIImage? = nil
    
    @Published var playerCharacter: Character!
    @Published var playerCharacterID: Character.ID
    
    @Published var charactersPresent = Set<Character.ID>()
    @Published var characters = [Character.ID : Character.Expression]()
    
    @Published var facilities = [Facility.ID : Facility]()
    var facilitiesMap = GKQuadtree(boundingQuad: GKQuad(quadMin: vector_float2(x: -10_000, y: -10_000), quadMax: vector_float2(x: 10_000, y: 10_000)), minimumCellSize: 40)
    
    @Published var droppedItems = [String : DroppedItem]()
    var droppedItemsMap = GKQuadtree(boundingQuad: GKQuad(quadMin: vector_float2(x: -10_000, y: -10_000), quadMax: vector_float2(x: 10_000, y: 10_000)), minimumCellSize: 40)
    
    var interactablesMap = GKQuadtree(boundingQuad: GKQuad(quadMin: vector_float2(x: -10_000, y: -10_000), quadMax: vector_float2(x: 10_000, y: 10_000)), minimumCellSize: 40)
    
    var asDictionary: [String:AnyHashable] {
        return [:]
    }
    
    var createID: String {
        return self.name.lowercased()
    }
    
    public init() {
        self.id = "placeholder ID"
        self.playerCharacter = nil
        self.playerCharacterID = "Unnamed Character"
        self.name = "Unnamed Venue"
        self.description = "Undescribed Place"
        self.region = Hexagon.Region(hexes: [
            Geography.TerrainSpecifier(.grassland, .plain),
            Geography.TerrainSpecifier(.grassland, .plain),
            Geography.TerrainSpecifier(.grassland, .plain),
            Geography.TerrainSpecifier(.grassland, .plain),
            Geography.TerrainSpecifier(.grassland, .plain),
            Geography.TerrainSpecifier(.grassland, .plain),
            Geography.TerrainSpecifier(.grassland, .plain),
            Geography.TerrainSpecifier(.grassland, .plain),
            Geography.TerrainSpecifier(.grassland, .plain),
        ], orientation: .point, width: 3)
        
        self.id = createID
    }
    
    public convenience init(named name: String, description: String) {
        self.init()
        self.name = name
        self.id = createID
        self.description = description
    }
    
    public convenience init(fromStatus status: RABackend_GameStatus) {
        self.init()
        
        self.id = status.venueData.id.id
        self.name = status.venueData.name
        self.description = status.venueData.description_p
        self.orientation = status.venueData.orientation.toOrientation
        self.bounds = CGSize(status.venueData.bounds)
        self.playerCharacterID = status.activeCharacter.id.id
        self.charactersPresent = Set(status.charactersPresentList.map {
            $0.characterID.id
        })
        
        self.characters = status.charactersPresentList
            .reduce([Character.ID : Character.Expression]()) { accum, element in
            var slices = accum
            let slice = Character.Slice(from: element)
            slices[id] = Character.Expression.character(character: slice)
            return slices
        }
        
        self.facilities = status.facilities.reduce([String:Facility]()) { accum, backendFacility in
            let facility = Facility(from: backendFacility)
            var facilities = accum
            facilities[facility.id] = facility
            return facilities
        }
        
        self.droppedItems = status.droppedItems.reduce([DroppedItem.ID : DroppedItem]()) { accum, backendDroppedItem in
            let droppedItem = DroppedItem(from: backendDroppedItem)
            var droppedItems = accum
            droppedItems[droppedItem.id] = droppedItem
            return droppedItems
        }
    }
    
    public func update(fromStatus status: RABackend_GameStatus) throws {
        self.name = status.venueData.name
        self.description = status.venueData.description_p
        self.bounds = CGSize(status.venueData.bounds)
        self.playerCharacterID = status.activeCharacter.id.id
        self.charactersPresent = Set(status.charactersPresentList.map {
            $0.characterID.id
        })
        
        updateCharacters(fromStatus: status)
        try? updateActiveCharacter(fromStatus: status)

        self.facilities = status.facilities.reduce([String:Facility]()) { accum, backendFacility in
            let facility = Facility(from: backendFacility)
            var facilities = accum
            facilities[facility.id] = facility
            return facilities
        }
        
        self.droppedItems = status.droppedItems.reduce([DroppedItem.ID : DroppedItem]()) { accum, backendDroppedItem in
            let droppedItem = DroppedItem(from: backendDroppedItem)
            var droppedItems = accum
            droppedItems[droppedItem.id] = droppedItem
            return droppedItems
        }
    }
    
    public subscript(source: ModelType, index: String) -> Any? {
        get throws {
            switch source {
            case .character:
                guard let character = self.characters[index]
                else { throw RAError.Unknown }
                return character
            case .facility:
                guard let facility = self.facilities[index]
                else { throw RAError.Unknown }
                return facility
            case .droppedItem:
                guard let droppedItem = self.droppedItems[index]
                else { throw RAError.Unknown }
                return droppedItem
            default:
                return nil
            }
        }
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let result = Venue()
        result.copy(from: self)
        return result
    }
    
    func copy(from other: any PhysicalVenue) {
        self.region = other.region
        self.name = other.name
        self.orientation = other.orientation
        self.bounds = other.bounds
        self.minimap = other.minimap
        self.playerCharacterID = other.playerCharacterID
        self.charactersPresent = other.charactersPresent
        self.facilities = other.facilities
        self.facilitiesMap = other.facilitiesMap
        self.interactablesMap = other.interactablesMap
        
        registerAllCharacters()
    }
    
    private func updateActiveCharacter(fromStatus status: RABackend_GameStatus) throws {
        let character = try Character(source: status.activeCharacter.characterData)
        
        self.characters[character.id] = Character.Expression.player(character: character)
    }
        
    private func updateCharacters(fromStatus status: RABackend_GameStatus) {
        guard let scene = GameClient.gameScene else { return }

        self.characters = status.charactersPresentList.reduce([String:Character.Expression]()) { accum, backendCharacter in
            let character = try! Character(source: backendCharacter)
            
            var characters = accum
            characters[character.id] = .character(character: character.slice)
            character.slice.type = .npc
            return characters
        }
        
        for characterNode in scene.characterNodes {
            if let character = characters[characterNode.name!] {
                print("$$$Updating:", characterNode.name!)
                
                var slice: Character.Slice = character.slice
                
                characterNode.character = slice
                
                characterNode.setFacing(to: slice.facing, for: scene.orientation)
                
                let position = GameClient.gameScene.hexagonMapNode.convert(position: slice.locality.position)
                characterNode.position = position

            }
        }
    }
    
    func registerAllCharacters() {
        for characterID in charactersPresent {
            guard let character = GameClient.gameClient.characters[characterID] else {
                print("RecordAllCharacters: Character Not Found.")
                continue
            }
            register(character: character)
        }
    }
    
    
    // TODO: change so that already registered characters are skipped
    func register(character: Character) {
        let venuePosition = character.locality.position
        let position = orientation.topology(radius: 100).convert(from: venuePosition)

        character.slice.characterMarker.gkQuadNode = self.interactablesMap.add(character.slice.characterMarker, at: position.vector_float2)
    }
}
