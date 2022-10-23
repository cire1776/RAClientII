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
    var name: String
    var description: String
    
    var orientation = Hexagon.Orientation.point
    
    var region: Hexagon.Region<Geography.TerrainSpecifier>

    var bounds = CGSize(width: 3, height: 3)
    
    var minimap: UIImage? = nil
    
    var playerCharacter: Character.ID
    @Published var charactersPresent = Set<Character.ID>()
    
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
        self.id = UUID().uuidString
        self.id = "placeholder ID"
        self.playerCharacter = "Unnamed Character"
        self.name = "Unnamed Venue"
        self.description = "Undescribed Place"
        self.region = Hexagon.Region()
        
        self.id = createID
    }
    
    public convenience init(named name: String, description: String) {
        self.init()
        self.id = createID
        self.name = name
        self.description = description
    }
    
    public convenience init(fromStatus status: RABackend_GameStatus) {
        self.init()
        
        self.id = status.venueData.id.id
        self.name = status.venueData.name
        self.description = status.venueData.description_p
        self.orientation = status.venueData.orientation.toOrientation
        self.bounds = status.venueData.bounds.toCGSize
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
        
        recordAllCharacters()
    }
    
    func setupDroppedItems() {
        let droppedItems = [
            Item(id: nil, type: "apple", quantity: 5)!,
            Item(id: nil, type: "hammer", quantity: 1)!,
        ]
        for item in droppedItems {
            let drop = DroppedItem(item, at: VenuePosition(hex: (0,0), x:10, y:10), within: 20)
            self.add(drop)
        }
    }
    
    func add(_ character: Character) {
        self.charactersPresent.insert(character.id)
        record(character: character)
    }
    
    func recordAllCharacters() {
        for characterID in charactersPresent {
            guard let character = GameClient.gameClient.characters[characterID] else {
                print("RecordAllCharacters: Character Not Found.")
                continue
            }
            record(character: character)
        }
    }
    
    func record(character: Character) {
        let venuePosition = character.locality.position
        let position = orientation.topology(radius: 100).convert(from: venuePosition)

        character.characterMarker.gkQuadNode = self.interactablesMap.add(character.characterMarker, at: position.vector_float2)
    }
    
    func remove(_ character: Character.ID) {
        self.charactersPresent.remove(character)
    }
}
