//
//  Dialogue.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/31/22.
//

import SpriteKit
import Foundation
import OrderedCollections

protocol Interchange {
    var quest: Quest { get }
    
    func currentPage(for character: Character) -> DialogueNode?
    
    func display(in parent: SKNode, for character: Character)

    func dismiss(for character: Character)
}

class Dialogue: Interchange {
    enum Instruction: Hashable {
        static func == (lhs: Dialogue.Instruction, rhs: Dialogue.Instruction) -> Bool {
            switch (lhs, rhs) {
            case (.message(let lhsValue), .message(let rhsValue)):
                return lhsValue == rhsValue
            case (.goto(let lhsValue1, let lhsValue2), .goto(let rhsValue1, let rhsValue2)):
                return lhsValue1 == rhsValue1 && lhsValue2 == rhsValue2
            case (.give(let lhsValue1, let lhsValue2), .give(let rhsValue1, let rhsValue2)):
                return lhsValue1 == rhsValue1 && lhsValue2 == rhsValue2
            case (.receive(let lhsValue1, let lhsValue2), .receive(let rhsValue1, let rhsValue2)):
                return lhsValue1 == rhsValue1 && lhsValue2 == rhsValue2
            case (.hasItem(let lhsValue1, let lhsValue2, let lhsValue3, let lhsValue4), .hasItem(let rhsValue1, let rhsValue2, let rhsValue3, let rhsValue4)):
                return lhsValue1 == rhsValue1 &&
                       lhsValue2 == rhsValue2 &&
                       lhsValue3 == rhsValue3 &&
                       lhsValue4 == rhsValue4
            case (.sequence(let lhsValue), .sequence(let rhsValue)):
                return lhsValue == rhsValue
            case (.random(let lhsValue1, let lhsValue2), .random(let rhsValue1, let rhsValue2)):
                return lhsValue1 == rhsValue1 && lhsValue2 == rhsValue2
            case (.end, .end):
                return true
            default:
                return false
            }
        }
        
        case message(String)
        case goto(interaction: String, index: UInt)
//        case endorse(endorsement: Endorsement.Key, buff: BuffSpecifier?)
//        indirect case hasEndorsement(_ key: Endorsement.Key, if: Instruction, else: Instruction)
//        case timed(key: Endorsement.Key, numberOfTicks: UInt, buff: BuffSpecifier?)
//        case timeout(key: Endorsement.Key, numberOfTicks: UInt, count: UInt, futureKey: Endorsement.Key, endorsement: Endorsement)
//        case increment(endorsement: Endorsement.Key)
//        case decrement(endorsement: Endorsement.Key)
//        case skill(skill: Skill, skillLevel: SkillLevel, rank: UInt)
        case give(_ itemType: ItemType.ID, quantity: UInt)
        case receive(_ itemType: ItemType.ID, quantity: UInt)
        indirect case hasItem(_ itemType: ItemType.ID, quantity: UInt, `if`: Instruction, `else`: Instruction)
        indirect case sequence([Instruction])
        indirect case random(chance: Double, _ instruction: Instruction)
        case end
    }
    
    enum Operator {
        case greaterThan(value: UInt, key: Endorsement.Key, true: Instruction, false: Instruction)
        case lessThan(value: UInt, key: Endorsement.Key, true: Instruction, false: Instruction)
        case equalTo(value: UInt, key: Endorsement.Key, true: Instruction, false: Instruction)
    }
    
    let quest: Quest
    
    let line: String
    
    let enabler: (String) -> String
    
    let originalResponses: OrderedDictionary<String,Instruction>
    var responses: OrderedDictionary<String,Instruction>
    
    var dialogueNode: DialogueNode? = nil
    
    func currentPage(for character: Character) -> DialogueNode? {
        self.responses = [:]
        
        for response in self.originalResponses {
            self.responses[enabler(response.key)] = response.value
        }
        
        return DialogueResponseNode(interaction: self, for: character)
    }
    
    init(in quest: Quest, line: String, responses: OrderedDictionary<String, Instruction>, enabler: @escaping ((String)-> String) = { $0 }) {
        self.quest = quest
        
        self.line = line
        self.originalResponses = responses
        self.responses = responses
        
        self.enabler = enabler
    }
    
    func display(in parent: SKNode, for character: Character) {
        self.dialogueNode = self.currentPage(for: character)
        parent.addChild(dialogueNode!)
    }
    
    private func display(for character: Character) {
        let parent = dialogueNode?.parent
        dialogueNode?.removeFromParent()
        
        display(in: parent!, for: character)
    }
    
    func process(_ instruction: Instruction, for character: Character) {
        switch instruction {
        case .message(let text):
            (dialogueNode! as? DialogueResponseNode)?.text = text
        case .give(let itemType, quantity: let quantity):
            character.add(item: Item(id: nil, type: itemType, quantity: quantity)!,authority: .predictive)
        case .receive(let itemType, quantity: let quantity):
            character.reduce(itemType: itemType, quantity: quantity)
        case .hasItem(let itemType, quantity: let quantity, if: let ifBranch, else: let elseBranch):
            process(character.has(itemOfType: itemType, quantity: quantity) ? ifBranch : elseBranch, for: character)
        case .goto(interaction: let tag, index: _):
            let nextInteraction = Quest.quests[quest.questName]!.interactions[tag]!
            
            let parent = (dialogueNode?.parent)!
            dialogueNode?.dismiss()
            
            nextInteraction.display(in: parent, for: character)
            return
        case .sequence(let instructions):
            for instruction in instructions {
                process(instruction, for: character)
            }
        case .end:
//            character.reset(quest.questName)
            dismiss(for: character)
            self.dialogueNode?.dismiss()
            self.dialogueNode = nil
//        case .endorse(endorsement: let key, buff: let buff):
//            character.add(key, buff: buff)
//        case .hasEndorsement(let key, if: let ifBranch, else: let elseBranch):
//            process(character.has(endorsement: key) ? ifBranch : elseBranch, for: character)
//        case .increment(endorsement: let key):
//            character.increment(key, buff: nil)
//        case .decrement(endorsement: let key):
//            character.decrement(key)
//        case .skill(skill: let skill, skillLevel: let skillLevel, rank: let rank):
//            character.update(skill.rawValue, skillLevel: skillLevel, rank: rank, xp: SkillLevel.xp(for: skillLevel, rank: rank))
//        case .timed(key: let key, numberOfTicks: let numberOfTicks, buff: let buff):
//            character.start(key, numberOfTicks: numberOfTicks, buff: buff)
//        case .timeout(key: let key, numberOfTicks: let numberOfTicks, count: let count, futureKey: let futureKey, endorsement: let endorsement):
//            character.start(key, numberOfTicks: numberOfTicks, count: count, futureKey: futureKey, endorsement: endorsement)
        case .random(chance: let chance, let instruction):
            if Double.random(in: 0..<1) <= chance {
                process(instruction, for: character)
            }
        }
    }
    
    func dismiss(for character: Character) {
        character.slice.occupied = false
    }
}
