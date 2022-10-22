//
//  SwitchDialogue.swift
//  OldRAClient
//
//  Created by Eric Russell on 6/11/22.
//

import Foundation
import SpriteKit

/*
 SwitchDialogue(forCharacter, .greaterThan(2, "Daylin Wooducutting Quest: Lurking"), .goto(interaction:"F", index:0), .goto(interaction:"G", index 0))
 */

class SwitchDialogue: Interaction {
    var quest: Quest

    var nextInteraction: Endorsement.Key?
    
    let comparator: Dialogue.Operator
    
    init(in quest: Quest,
         _ comparator: Dialogue.Operator) {
        self.quest = quest
        self.comparator = comparator
        nextInteraction = nil
    }

    func currentPage(for character: Character) -> DialogueNode? {
        // not implemented
        abort()
    }
    
    func display(in parent: SKNode, for character: Character) {
        // not implemented
        abort()
    }

    func dismiss(for character: Character) {
        // not implemented
        abort()
    }
}
