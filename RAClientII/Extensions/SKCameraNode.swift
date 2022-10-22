//
//  SKCameraNode.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/30/22.
//

import SpriteKit

extension SKCameraNode {
    static func setup(scene: GameScene) {
        let camera = SKCameraNode()
        camera.setScale(0.05)
        camera.physicsBody = SKPhysicsBody()
        camera.physicsBody?.velocity = .zero
        camera.physicsBody?.linearDamping = 13.0
        camera.zPosition = 100_000
        scene.camera = camera
        scene.addChild(camera)

        let area = scene.hexagonMapNode.calculateAccumulatedFrame()
        let constraint = SKConstraint.positionX(SKRange(
                                                    lowerLimit: area.minX,
                                                    upperLimit: area.maxX
                                                ),
                                                y: SKRange(
                                                    lowerLimit: area.minY, upperLimit: area.maxY)
                                                )

        camera.constraints = [constraint]
    }
}
