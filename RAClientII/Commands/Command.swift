//
//  Command.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/28/22.
//

import Foundation

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
