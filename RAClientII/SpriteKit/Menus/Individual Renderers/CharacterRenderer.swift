//
//  CharacterRenderer.swift
//  OldRAClient
//
//  Created by Eric Russell on 6/5/22.
//

import Foundation
import SpriteKit

struct CharacterRenderer: MenuRenderer {
    struct CharacterActions {
        var button: String
        var operation: String
        var enablePredicate : (Facility) -> Bool
        
        public func enablePredicate(facility: Facility) -> Bool {
            facility.interactions.contains(button)
        }
    }
    
    let character: Character.Slice
    
    let actions: [CharacterActions]
    
    init(for character: Character.Slice) {
        self.actions = []
        self.character = character
    }
    
    func render(to container: Container, menuTree: MenuTree) {
        container.title = character.displayName
        
        for _ in self.actions.reversed() {
            
//            let command = Command.StartDialogue()
//
//            container.accept(menuOption: SimpleMenuOption(text: action.button) {
//                command.execute(for: gameScene.playerNode.character)
//            })
        }
    }
}

extension Command {

}
