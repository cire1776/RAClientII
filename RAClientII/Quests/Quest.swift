//
//  Quest.swift
//  OldRAClient
//
//  Created by Eric Russell on 6/3/22.
//

import Foundation
import OrderedCollections
import SpriteKit

struct Quest {
    static var character: Character! = nil
    
    static var quests: [String : Quest] = [:]
    
    static var interactions: [String : [String : Interchange]] = [:]
    
    static func add(at questName: String,
                    _ interactions: [String : Interchange]) {
        Self.interactions[questName] = interactions
    }
    
    let questName: String
    
    var interactionTag: String = ""
    var index : UInt = 0
    var interactions: [String : Interchange] = [:]
    
    init(_ questName: String, _ interactions: (Quest) -> [String : Interchange]) {
        Self.character = Game.game?.player
        self.questName = questName
        self.interactions = interactions(self)
        
        Quest.quests[questName] = self
    }
    
    func display(in parent: SKNode, for character: Character) {
//        if case let .interaction(tag: tag, index: _) = character.endorsements[questName] {
//            let interactions =
//            Quest.quests[questName]!.interactions
//            interactions[tag]?.display(in: parent, for: character)
//        } else {
//            character.endorsements[questName] = .interaction(tag: "A", index: 0)
//            self.display(in: parent, for: character)
//        }
    }
}

