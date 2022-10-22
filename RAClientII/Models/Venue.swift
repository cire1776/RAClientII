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
    
    init() {
        self.id = UUID().uuidString
        self.playerCharacter = "Unnamed Character"
        self.name = "Unnamed Venue"
        self.description = "Undescribed Place"
        self.region = Hexagon.Region()
    }
    
    convenience init(named name: String, description: String) {
        self.init()
        self.name = name
        self.description = description
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
