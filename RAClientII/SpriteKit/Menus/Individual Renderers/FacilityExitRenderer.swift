//
//  FacilityExitRenderer.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/6/22.
//

import SpriteKit

struct FacilityExitRenderer: MenuRenderer {
    func render(to container: Container, menuTree: MenuTree) {
        let gameScene = container.scene as! GameScene
        let characterNode = gameScene.playerNode!
        
        container.accept(menuOption: SimpleMenuOption(text: "Cancel", color: .systemRed) {
//            Command.CancelWork(characterNode: characterNode)
        })
    }
}

