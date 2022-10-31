//
//  HexAdorner.swift
//  Royal Ambition
//
//  Created by Eric Russell on 2/6/22.
//

import Foundation
import CoreGraphics
import SpriteKit

struct HexAdorner {
    let tileSize: CGSize
    let adornmentSprite: SKSpriteNode
    let parentNode: SKNode
    let targetLayerName: String
    let centerOfTile: (Int, Int) -> CGPoint
    
    var adorners = [String: SKNode]()
    
    init() {
        tileSize = .zero
        adornmentSprite = SKSpriteNode()
        parentNode = SKNode()
        targetLayerName = ""
        centerOfTile = { _,_ in .zero }
    }
    
    init(tileSize: CGSize, adornmentSprite: SKSpriteNode, parentNode: SKNode, targetLayer: String, centerOfTile: @escaping (Int, Int) -> CGPoint) {
        self.tileSize = tileSize
        self.adornmentSprite = adornmentSprite
        self.parentNode = parentNode
        self.targetLayerName = targetLayer
        self.centerOfTile = centerOfTile
    }

    mutating func adorn(atColumn column: Int, row: Int, with angleMask: String = "xxxxxx", offset: CGPoint = .zero) {
        if angleMask == "" { return }

        var selectionAdornment: SKSpriteNode
        
        selectionAdornment = fetchOrMakeAdornment(with: angleMask)
        
        place(adornment: selectionAdornment, atColumn: column, row: row, offset: offset)
    }
    
    private mutating func fetchOrMakeAdornment(with angleMask: String) -> SKSpriteNode {
        
        guard adorners[angleMask] == nil else {
            let adorner = adorners[angleMask]!.copy() as! SKSpriteNode
            return adorner
        }
        
        let originalMask = angleMask
        var angleMask = angleMask
        

        let selectionAdornment = SKSpriteNode()
        
        for angle in stride(from: 0.0, to: 360.0, by: 60.0) {
            let fragment = makeFragment(for: angle, with: &angleMask)
            if let fragment = fragment {
                selectionAdornment.addChild(fragment)
            }
        }

        adorners[originalMask] = selectionAdornment
        
        return selectionAdornment
    }

    private func place(adornment selectionAdornment: SKSpriteNode, atColumn column: Int, row: Int, offset: CGPoint = .zero) {
        let targetLayer = parentNode.childNode(withName: targetLayerName)!
        targetLayer.addChild(selectionAdornment)
        
        selectionAdornment.size = CGSize(width: tileSize.width, height: tileSize.height)
        
        // scale to achieve slight overlap of borders
        let borderOverlapAdjustment = 1.10
        selectionAdornment.xScale = borderOverlapAdjustment
        selectionAdornment.yScale = borderOverlapAdjustment
        
        var position = centerOfTile(column, row)
        position = targetLayer.convert(position, from: parentNode)
        
        let offsetX = -((tileSize.width / 2 + 60) + CGFloat(offset.x))
        let offsetY = -((tileSize.height / 2 + 60) + CGFloat(offset.y))
        
        selectionAdornment.position = CGPoint(x: position.x + offsetX, y: position.y + offsetY)
    }
    
    private func makeFragment(for angle: Double, with angleMask: inout String) -> SKNode? {
        let maskValue = angleMask.first!
        angleMask = String(angleMask.dropFirst())
        if maskValue == " " { return nil }

        let fragment = adornmentSprite.copy() as! SKSpriteNode
        fragment.zRotation = angle.degreesToRadians
        fragment.position = CGPoint( x: tileSize.width / 2 - 10, y: tileSize.height / 2 - 30)
        
        return fragment
    }
}

