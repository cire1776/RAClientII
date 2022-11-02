//
//  FruitTreeMenuRenderer.swift
//  RAClientII
//
//  Created by Eric Russell on 11/1/22.
//

import Foundation

struct FruitTreeMenuRenderer: MenuRenderer {
    struct TreeAction {
        var button: String
        var operation: String
        var enablePredicate : (Facilities.Tree) -> Bool
    }
    
    let tree: Facilities.FruitTree
    
    let actions: [TreeAction]
    
    init(for tree: Facilities.FruitTree) {
        self.tree = tree
        
        actions = [
            TreeAction(button: "Meditate", operation: Constants.treeMeditationOperation) { tree in
                tree.category == .snag || tree.category == .mature
            },
            TreeAction(button: "Pick Fruit", operation: Constants.fruitTreePickingOperation) { tree in
                tree.category != .seedling && tree.category != .whip
            },
            TreeAction(button: "Chop Wood", operation: Constants.treeChoppingOperation) { tree in
                tree.category != .seedling && tree.category != .whip
            },
            TreeAction(button: "Tend", operation: Constants.treeTendingOperation) {_ in
                true
            },
            TreeAction(button: "Fell", operation: Constants.treeFellingSnagOperation) { tree in
                tree.category == .snag
            },
            TreeAction(button: "Fell", operation: Constants.treeFellingMatureOperation) { tree in
                tree.category == .mature
            },
            TreeAction(button: "Fell", operation: Constants.treeFellingSemiMatureOperation) { tree in
                tree.category == .semiMature
            },
            TreeAction(button: "Fell", operation: Constants.treeFellingStandardOperation) { tree in
                tree.category == .standard
            },
            TreeAction(button: "Fell", operation: Constants.treeFellingMaidenOperation) { tree in
                tree.category == .maiden
            },
            TreeAction(button: "Harvest", operation: Constants.treeHarvestingOperation) { tree in
                tree.category == .seedling || tree.category == .whip
            }
        ]
    }
    
    func render(to container: Container, menuTree: MenuTree) {
        container.title = "\(tree.category) Tree".capitalized
        
        for action in self.actions.reversed() {
            let gameScene = container.scene as! GameScene
            
            let command = Command.TreeCommand(on: tree, operationName: action.operation, for: gameScene.playerNode)
            
            guard action.enablePredicate(tree),
                  command.canExecute(for: GameClient.gameClient.player) else { continue }
            
            container.accept(menuOption: SimpleMenuOption(text: action.button) {
                command.execute(for: gameScene.playerNode.character)
            })
        }
    }
}
