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
    
    @Published var playerCharacter: Character.ID
    @Published var charactersPresent = Set<Character.ID>()
    @Published var characters = [Character.ID : Character]()
    
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
        self.playerCharacter = "Unnamed Character"
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
        self.playerCharacter = status.activeCharacter.id.id
        self.charactersPresent = Set(status.charactersPresentList.map {
            $0.characterID.id
        })
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
    
    public func update(fromStatus status: RABackend_GameStatus) {
        self.name = status.venueData.name
        self.description = status.venueData.description_p
        self.bounds = CGSize(status.venueData.bounds)
        self.playerCharacter = status.activeCharacter.id.id
        self.charactersPresent = Set(status.charactersPresentList.map {
            $0.characterID.id
        })
        self.characters = status.charactersPresentList.reduce([String:Character]()) { accum, backendCharacter in
            let character = try! Character(source: backendCharacter)
            
            var characters = accum
            characters[character.id] = character
            return characters
        }
        updateCharacters()
        
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
    
    public subscript(source: ModelType, index: String) -> AnyObject? {
        get throws {
            switch source {
            case .character:
                guard let character = self.characters[index]
                else { throw ModelType.Unknown() }
                return character
            case .facility:
                guard let facility = self.facilities[index]
                else { throw ModelType.Unknown() }
                return facility
            case .droppedItem:
                guard let droppedItem = self.droppedItems[index]
                else { throw ModelType.Unknown() }
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
        self.playerCharacter = other.playerCharacter
        self.charactersPresent = other.charactersPresent
        self.facilities = other.facilities
        self.facilitiesMap = other.facilitiesMap
        self.interactablesMap = other.interactablesMap
        
        registerAllCharacters()
    }
    
    func updateCharacters() {
        guard let scene = GameClient.gameScene else { return }
        
        for characterNode in scene.characterNodes {
            if let character = characters[characterNode.name!] {
                print("$$$Updating:", characterNode.name!)
                characterNode.character = character
                
                characterNode.setFacing(to: character.facing, for: scene.orientation)
                
                let position = GameClient.gameScene.hexagonMapNode.convert(position: character.locality.position)
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

        character.characterMarker.gkQuadNode = self.interactablesMap.add(character.characterMarker, at: position.vector_float2)
    }
}
