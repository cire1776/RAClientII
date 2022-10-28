//
//  Character.swift
//  CommonLibrary
//
//  Created by Eric Russell on 9/17/22.
//

import Foundation
import OrderedCollections
import GameplayKit

public class Character: Hashable, Identifiable, MainItemHolding {
    public enum Class: Codable {
        case player, character, npc
    }
    
    public enum Expression {
        case player(character: Character)
        case character(character: Slice)
        case npc(character: Slice)
    
        public var slice: Character.Slice {
            switch self {
            case .player(character: let char):
                return char.slice
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
        
        public var occupied = false
        
        init(id: String, displayName: String, type: Character.Class, venueID: Venue.ID, locality: Locality, facing: Facing, occupied: Bool = false) {
            self.id = id
            self.displayName = displayName
            self.type = type
            self.venueID = venueID
            self.locality = locality
            self.facing = facing
            self.occupied = occupied
        }
        
        init(from data: RABackend_CharacterData) {
            self.id = data.characterID.id
            self.displayName = data.displayName
            self.type = .character
            self.venueID = data.venue.id
            self.locality = Locality(from: data.locality)
            self.facing = Facing(data.facing)
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
    
    internal init(id: String, displayName: String, type: Class, venue: Venue, locality: Locality) {
        self.slice = Slice(
            id: id,
            displayName: displayName,
            type: type,
            venueID: venue.id,
            locality: locality,
            facing: 0
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
        else { throw RAError.Unknown }
        
        self.init(id: characterData.characterID.id, displayName: characterData.displayName, type: .character, venue: venue, locality: Locality(from: characterData.locality))
        self.slice.type = .character
    }
}

