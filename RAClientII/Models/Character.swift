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
    
    public typealias ID = String
    
    public static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.id == rhs.id
    }
    
    public var id: String
   
    public var displayName: String = "INVALID"
    public var type: Character.Class

    @Published public var venue: Venue
    @Published public var locality: Locality
    @Published var facing: Facing
    
    public var characterMarker = Marker()
    
    public var occupied = false
    
    var items = [String : Item]()
    
    var isUsingSubordinate: Bool {
        false
    }
    
    internal init(id: String, displayName: String, type: Class, venue: Venue, locality: Locality) {
        self.id = id
        self.displayName = displayName
        self.type = type
        self.venue = venue
        self.locality = locality
        self.facing = 0
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

            self.type = character.type == .player ? .player : .character
            
            super.init()
        }
    }
    
    convenience init(source characterData: RABackend_CharacterData) throws {
        guard let venue = Game.game.venue,
              venue.id == characterData.venue.id
        else { throw ModelType.Unknown() }
        
        self.init(id: characterData.characterID.id, displayName: characterData.displayName, type: .character, venue: venue, locality: Locality(from: characterData.locality))
        self.type = .character
    }
}
