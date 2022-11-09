//
//  Character.swift
//  CommonLibrary
//
//  Created by Eric Russell on 9/17/22.
//

import Foundation
import OrderedCollections
import GameplayKit

/// This struct provides the full amount of data that the client is able to have about the player's active character.
public class ActiveCharacter: Identifiable, ObservableObject, Hashable, MainItemHolding {
    public static func == (lhs: ActiveCharacter, rhs: ActiveCharacter) -> Bool {
        lhs.id == rhs.id
    }
    
    public var id: String
    
    public var slice: Character.Slice
    
    public var locality: Locality {
        get {
            return slice.locality
        }
        
        set {
            slice.locality = newValue
        }
    }
    
    public var items: [Item.ID : Item]
    
    public var mountingPoints: Equipping.MountingPoints
    
    public var isUsingSubordinate: Bool = false
    
    public var occupied: Bool { slice.occupied }
    
    public init(_ character: Character) {
        self.id = character.id
        self.slice = character.slice
        self.slice.type = character.slice.type
        self.slice.facing = character.slice.facing
        self.slice.operation = nil
        
        // use the slice version to avoid using self too early.
        self.slice.locality = character.locality
        self.items = [:]
        self.mountingPoints = Equipping.MountingPoints()
    }
    
    public init(_ source: RABackend_CharacterData) {
        self.id = source.characterID.id
        self.slice = Character.Slice(from: source)
        
        self.slice.operation = nil
        
        self.items = [:]
        self.mountingPoints = Equipping.MountingPoints()
    }
    
    public init(_ activeCharacter: ActiveCharacter) {
        self.id = activeCharacter.id
        self.slice = activeCharacter.slice
        self.slice.type = .player
        self.slice.facing = activeCharacter.slice.facing
        self.slice.operation = nil
        
        // use the slice version to avoid using self too early.
        self.slice.locality = activeCharacter.locality
        self.items = [:]
        self.mountingPoints = activeCharacter.mountingPoints
    }
    
    public init(from activeCharacter: RABackend_ActiveCharacterData) {
        self.id = activeCharacter.characterData.characterID.id
        self.slice = Character.Slice(from: activeCharacter.characterData)
        
        self.slice.operation = nil
        
        self.items = [:]
        self.items = activeCharacter.items
            .reduce(into: [Item.ID : Item]()) { items, item in
                items[item.itemID.id] = Item(source: item)
            }
        
        self.mountingPoints = activeCharacter.mountingPoints.mountingPoints
            .reduce(into: Equipping.MountingPoints()) { points, mountingPoint in
                points.mountingPoints[Equipping.Slot(rawValue: mountingPoint.key)!]?.insert(mountingPoint.value)
            }
    }
    
    public init(from characterData: RABackend_CharacterData) {
        self.id = characterData.characterID.id
        self.slice = Character.Slice(from: characterData)
        self.items = [:]
        self.mountingPoints = Equipping.MountingPoints()
    }
    
    public func update(from characterData: RABackend_CharacterData) {
        self.id = characterData.characterID.id
        self.slice = Character.Slice(from: characterData)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    func canAccept(_ item: Item) -> Bool {
        true
    }
}

public class Character: Hashable, Identifiable, MainItemHolding {
    public enum Class: String, Codable, CaseIterable {
        case player, character, npc
    }
    
    public enum Expression {
        case player(character: ActiveCharacter)
        case character(character: Slice)
        case npc(character: Slice)
    
        public var slice: Character.Slice {
            switch self {
            case .player(character: let activeChar):
                return activeChar.slice
            case .character(character: let charSlice):
                return charSlice
            case .npc(character: let charSlice):
                return charSlice
            }
        }
    }
    
    public class Slice: ObservableObject {
        public var id: String = "INVALID"
       
        public var displayName: String = "INVALID"
        public var type: Character.Class = .character

        @Published public var venueID: Venue.ID = ""
        @Published public var locality: Locality = .zero
        @Published var facing: Facing
        
        public var characterMarker = Marker()
        
        public var operation: Operation?
        public var occupied: Bool {
            operation != nil || locality.isMoving
        }
        
        init(id: String, displayName: String, type: Character.Class, venueID: Venue.ID, locality: Locality, facing: Facing, operation: Operation?=nil) {
            self.id = id
            self.displayName = displayName
            self.type = type
            self.venueID = venueID
            self.locality = locality
            self.facing = facing
            self.operation = operation
        }
        
        init(from data: RABackend_CharacterData ) {
            self.id = data.characterID.id
            self.displayName = data.displayName
            self.type = data.type.asCharacterClass
            self.venueID = data.venue.id
            self.locality = Locality(from: data.locality)
            self.facing = Facing(data.facing)
        }
        
        init(from data: RABackend_ActiveCharacterData) {
            self.id = data.characterData.characterID.id
            self.displayName = data.characterData.displayName
            self.type = .player
            self.venueID = data.characterData.venue.id
            self.locality = Locality(from: data.characterData.locality)
            self.facing = Facing(data.characterData.facing)
        }
        
        public init(_ activeCharacter: ActiveCharacter) {
            self.id = activeCharacter.id
            self.displayName = activeCharacter.slice.displayName
            self.type = .player
            self.venueID = activeCharacter.slice.venueID
            self.locality = Locality(locality: activeCharacter.slice.locality)
            self.facing = Facing(activeCharacter.slice.facing)
            self.operation = activeCharacter.slice.operation
        }
    }

    public typealias ID = String
    
    public static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.id == rhs.id
    }
    
    public var id: String {
        get { slice.id }
        set { slice.id = newValue }
    }
    
    public var locality: Locality {
        get { slice.locality }
        set { slice.locality = newValue }
    }
    
    public var facing: Facing {
        get { slice.facing }
        set { slice.facing = newValue }
    }

    var slice: Character.Slice
    
    var items = [Item.ID : Item]()
    
    public var mountingPoints: Equipping.MountingPoints!
    
    public var buffs = [BuffSpecifier.ID : BuffSpecifier]()
    
    var isUsingSubordinate: Bool {
        false
    }
    
    var occupied: Bool {
        self.slice.operation != nil || locality.isMoving
    }
    
    internal init(id: String, displayName: String, type: Class, venue: Venue, locality: Locality,operation: Operation?) {
        self.slice = Slice(
            id: id,
            displayName: displayName,
            type: type,
            venueID: venue.id,
            locality: locality,
            facing: 0,
            operation: operation
        )
    }
    
    public convenience init(from source: RABackend_ActiveCharacterData) {
        let venue = try! Game.game[.venue, source.characterData.venue.id] as? Venue
        
        self.init(
            id: source.characterData.characterID.id,
            displayName: source.characterData.displayName,
            type: .player,
            venue: venue!,
            locality: .init(from: source.characterData.locality),
            operation: Operation(from: source.operation)
        )
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    func canAccept(_ item: Item) -> Bool {
        true
    }
}

public extension Character {
    class Marker: NSObject, Interactable {
        let character: Character!
        
        let type: InteractableType
        
        var gkQuadNode: GKQuadtreeNode? = nil
        
        var position: VenuePosition {
            get {
                character.locality.position
            }
            
            set {
                character.locality.position = newValue
            }
        }
        
        override init() {
            self.character = nil
            self.type = .other
            super.init()
        }
        
        init(character: Character) {
            self.character = character

            self.type = character.slice.type == .player ? .player : .character
            
            super.init()
        }
    }
    
    convenience init(source characterData: RABackend_CharacterData) throws {
        guard let venue = Game.game.venue,
              venue.id == characterData.venue.id
        else { throw RAError.Unknown(reason:"@@@reason: Problem loading venue") }
        
        self.init(id: characterData.characterID.id,
                  displayName: characterData.displayName,
                  type: characterData.type.asCharacterClass,
                  venue: venue,
                  locality: Locality(from: characterData.locality),
                  operation: Operation(from: characterData.operation)
        )
    }
    
    convenience init(source activeCharacter: ActiveCharacter) throws {
        guard let venue = Game.game.venue,
              venue.id == activeCharacter.slice.venueID
        else { throw RAError.Unknown(reason:"@@@reason: Problem loading venue") }

        self.init(id: activeCharacter.id,
                      displayName: activeCharacter.slice.displayName,
                  type: activeCharacter.slice.type,
                  venue: venue,
                  locality: activeCharacter.locality,
                  operation: activeCharacter.slice.operation
        )
    }
}

