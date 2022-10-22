//
//  UIDelegate.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/28/22.
//

import SpriteKit

class UIDelegate {
    let scene: GameScene
    var dialogueNode: DialogueNode?
    
    var lastDragLocation: CGPoint?
    var originalScaleFactor: CGFloat = 1.0
    var lastRotation: CGFloat = 0.0
    var startingRotation: CGFloat = 0.0
    
    var hexagonMap: Hexagon.Map<Geography.TerrainSpecifier> {
        scene.hexagonMap!
    }
    
    var hexagonMapNode: HexagonMapNode {
        scene.hexagonMapNode!
    }
    
    var playerNode: CharacterNode {
        scene.playerNode!
    }
    var screenDragInProgress = false
    var movementAction: SKAction? = nil
    var movementLine: SKShapeNode? = nil
    
    var selectedFacility: Facility?
    
    var displayedMenu: MenuTree
    var debugMenu: MenuTree
    
    init() {
        self.scene = GameScene(size: .zero)
        self.displayedMenu = MenuTree()
        self.debugMenu = MenuTree()
    }
    
    init(scene: GameScene) {
        self.scene = scene
        
        self.displayedMenu = MenuTree()
        self.debugMenu = MenuTree()
        
        self.displayedMenu = MenuTree() { self.selectedFacility = nil }
    }
    
    func setup(view: SKView) {
        view.isMultipleTouchEnabled = true
        
//        self.setupZoom(view)
//        self.setupRotateCharacter(view)
//        self.setupTaps(view)
//        self.setupMovement(view)
//        self.setupDebugMenu(view)
    }
}
