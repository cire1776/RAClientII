//
//  PlayerRenderer.swift
//  OldRAClient
//
//  Created by Eric Russell on 6/24/22.
//

import Foundation
import SpriteKit

struct PlayerRenderer: MenuRenderer {
    struct PlayerActions {
        var button: String
        var operation: String
//        var enablePredicate : (Facilities.Tree) -> Bool
        
        public func enablePredicate(facility: Facility) -> Bool {
            facility.interactions.contains(button)
        }
    }
    
    let character: Character.Slice
    
    let actions: [PlayerActions]
    
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
