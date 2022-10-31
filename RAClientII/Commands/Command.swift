//
//  Command.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/28/22.
//

import Foundation

public enum ClientCommand: Codable {
    case nop, report
    case wait(UInt64)
    case connect, close
    case beginOperation, cancelOperation
    case command
    case face(facing: UInt)
    case move(destination: VenuePosition)
    case addWaypoint(destination: VenuePosition, duration: UInt64)
    case abortMovement, abortLastWaypoint
    case consume(itemID: Item.ID)
    case use(itemID: Item.ID)
    case drop(itemID: Item.ID)
    case pickup(droppedItemID: DroppedItem.ID)
    case equip(itemID: Item.ID)
    case unequip(itemID: Item.ID)
}

class Command {
    class Reference: Codable {
        var reference: String
        
        init(reference: String) {
            self.reference = reference
        }
    }

    class EmptyReference: Command.Reference {
        init() {
            super.init(reference: "")
        }
        
        required init(from decoder: Decoder) throws {
            try super.init(from: decoder)
        }
        
        override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)
        }
    }
    
    static var player: Character!
    
    var endorsementsRequired: ([Endorsement.Key],[Endorsement.Key]) {
        return ([],[])
    }
    
    func canExecute(for player: Character) -> Bool {
//        if player.has(endorsements: endorsementsRequired.0) { return true }
//        return player.has(endorsements: endorsementsRequired.1, emptyResult: false)
        true
    }
    
    func execute(for character: Character) {}
}
