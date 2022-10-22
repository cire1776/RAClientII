//
//  DroppedItemNode.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/18/22.
//

import SpriteKit

class DroppedItemNode : SKNode {
    init(droppedItem: DroppedItem, holder: EntityHolder) {
        super.init()
        
        let position = holder.convert(position: droppedItem.position)
        self.position = position
        
        let base = createSprite()
        base.color = .blue
        
        let sparkle = createSprite()
        sparkle.color = .white
        sparkle.zPosition -= 1
        sparkle.zRotation = 45.degreesToRadians
        sparkle.setScale(0.75)
        
        holder.addChild(self)
        self.animate(sparkle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSprite() -> SKSpriteNode {
        let texture = SKTexture(imageNamed: "DroppedItemMarker.png")
        let diameter: CGFloat = 2
        
        let sprite = SKSpriteNode(color: .yellow, size: .zero)
        
        sprite.texture = texture
        sprite.size = CGSize(width: diameter, height: diameter)
        sprite.position = .zero
        sprite.colorBlendFactor = 1.0
        sprite.zPosition = Constants.markerLevel
        
        self.addChild(sprite)
        
        return sprite
    }
    
    func animate(_ target: SKNode) {
        let scalingAnimation = SKAction.scale(by: 2.0, duration: 0.75)
        let unscalingAnimation = SKAction.scale(by: 0.5, duration: 0.75)
        let chain = SKAction.sequence([scalingAnimation,unscalingAnimation])
        let forever = SKAction.repeatForever(chain)
        target.run(forever)
    }
}
