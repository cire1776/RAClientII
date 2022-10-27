//
//  Monologue.swift
//  OldRAClient
//
//  Created by Eric Russell on 6/11/22.
//

import Foundation
import SpriteKit

class Monologue: Interaction {
    var quest: Quest

    var tag: String = ""
    
    let lines: [Dialogue.Instruction]
    var lineIndex: Int = 0
    var dialogueNode: DialogueNode? = nil

    func currentLine(for character: Character) -> String? {
        if case let .message(message) = lines[lineIndex] {
            return message
        }
        return nil
    }
    
    var isDone: Bool {
        lineIndex + 1 >= lines.count || lines[lineIndex + 1] == .end
    }
    
    init(in quest: Quest, lines: [Dialogue.Instruction]) {
        self.quest = quest
        self.lines = lines
    }
    
    func currentPage(for character: Character) -> DialogueNode? {
//        if case let .interaction(tag: tag, index: index) = character.endorsements[quest.questName] {
//            self.tag = tag
//            lineIndex = Int(index)
//
//            if let current = currentLine(for: character) {
//                return MonologueNode(interaction: self, text: current, for: character)
//            }
//            print("Endorsement not valid")
//            return nil
//        }
//        print("Endorsement not found")
        return nil
    
    }
    
    func display(in parent: SKNode, for character: Character) {
        self.dialogueNode = self.currentPage(for: character)
        if let dialogueNode = dialogueNode {
            parent.addChild(dialogueNode)
        }
    }
    
    func dismiss(for character: Character) {
        character.slice.occupied = false
        self.dialogueNode = nil
    }
    
    func advance(for character: Character) {
        print("advancing")
        
        let questName = self.quest.questName
       
        guard !isDone else {
//            character.endorsements.removeValue(forKey: questName)
            self.dialogueNode?.dismiss()
            self.dialogueNode?.removeFromParent()
            return
        }
        
        lineIndex += 1
        
        switch lines[lineIndex] {
        case .end:
            // is handled by isDone block above.
            return
        case .message(_):
//            character.endorsements[questName] = .interaction(tag: self.tag, index: UInt(lineIndex))
            
            let parent = self.dialogueNode?.parent
            self.dialogueNode?.removeFromParent()
            self.dialogueNode = self.currentPage(for: character)
            parent?.addChild(self.dialogueNode!)
            return
        case .goto(interaction: let tag, index: _):
            let nextInteraction = Quest.quests[quest.questName]!.interactions[tag]!
            
            let parent = (dialogueNode?.parent)!
            self.dialogueNode?.removeFromParent()
            dialogueNode?.dismiss()
            
            nextInteraction.display(in: parent, for: character)
            return
//        case .endorse(endorsement: let key, buff: let buff):
//            character.add(key, buff: buff)
//        case .increment(endorsement: let key):
//            character.increment(key, buff: nil)
//        case .skill(skill: let skill, skillLevel: let skillLevel, rank: let rank):
//            // xp needs to be adjusted for skillLevel and rank.
//            character.update(skill.rawValue, skillLevel: skillLevel, rank: rank, xp: SkillLevel.xp(for: skillLevel, rank: rank))
        case .give(let itemType, quantity: let quantity):
            character.add(item: Item(id: nil, type: itemType, quantity: quantity)!,authority: .predictive)
//        case .timeout(key: let key, numberOfTicks: let numberOfTicks, count: let count, futureKey: let futureKey, endorsement: let futureEndorsement):
//            character.start(key, numberOfTicks: numberOfTicks, count: count, futureKey: futureKey, endorsement: futureEndorsement)
        default:
            break
//            character.endorsements[questName] = .interaction(tag: self.tag, index: UInt(lineIndex))
        }
        
        advance(for: character)
    }
}
