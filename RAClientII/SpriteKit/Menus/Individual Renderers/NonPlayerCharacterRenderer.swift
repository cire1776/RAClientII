//
//  NonPlayerCharacterRenderer.swift
//  OldRAClient
//
//  Created by Eric Russell on 6/5/22.
//

import SpriteKit

struct NonPlayerCharacterRenderer: MenuRenderer {
    struct CharacterActions {
        var button: String
        var exchange: Exchange
        
        init(exchange: Exchange) {
            self.button = ""
            self.exchange = exchange
            
            if case let .quest(label: label, questID: _, enablers: _) = exchange {
                self.button = label
            }
        }
    }
    
    let character: Character.Slice
    
    init(for character: Character.Slice) {
        self.character = character
    }
    
    func render(to container: Container, menuTree: MenuTree) {
        container.title = character.displayName
        
        var actions = [CharacterActions]()
        
//        for exchange in character.availableExchanges(given: GameClient.gameClient.player) {
//            actions.append(CharacterActions(exchange: exchange))
//        }
        
        for action in actions.reversed() {
            let gameScene = container.scene as! GameScene
            
            let command = Command.StartDialogue(exchange: action.exchange)
            
            container.accept(menuOption: SimpleMenuOption(text: action.button) {
                command.execute(for: gameScene.playerNode.character)
            })
        }
    }
}

extension Command {
    struct StartDialogue {
        var exchange: Exchange
        
        func canExecute(for character: Character.Slice) -> Bool {
            // This is always true because availableExchanges only presents executable options.
            return true
        }
        
        func execute(for character: Character.Slice) {
            if case let .quest(label: _, questID: questID, enablers: _) = self.exchange {
                print(Quest.quests)
                Quest.quests[questID]!.display(in: GameClient.gameScene.camera!, for: Quest.character)
            }
        }
    }
}
