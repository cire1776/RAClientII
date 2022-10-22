//
//  SKNode.swift
//  RAClient
//
//  Created by Eric Russell on 4/26/22.
//

import SpriteKit
import SwiftUI

public extension SKNode {
    func drawLine(from: CGPoint, to: CGPoint, styler: ((SKShapeNode)->Void)?=nil) -> SKNode {
        let line = SKShapeNode()
        let path = CGMutablePath()
        path.addLines(between: [from, to])
        line.path = path
        line.strokeColor = .black
        line.lineWidth = 2
        self.addChild(line)
        
        styler?(line)
        
        return line
    }
    
    func drawDashedLine(from: CGPoint, to: CGPoint, pattern: [CGFloat], styler: ((SKShapeNode)->Void)?=nil) -> SKNode {
        let path = CGMutablePath()
        path.addLines(between: [from, to])
        
        let dashed = path.copy(dashingWithPhase: 2, lengths: pattern)

        let line = SKShapeNode(path: dashed)
        
        line.strokeColor = .black
        line.lineWidth = 2
        self.addChild(line)
        
        styler?(line)
        
        return line
    }
    
    func border(color: UIColor, lineWidth: CGFloat, styler:  ((SKShapeNode)->Void)? = nil) {
        let border = SKShapeNode(rect: self.calculateAccumulatedFrame())
        
        self.parent!.addChild(border)
        
        border.strokeColor = color
        border.lineWidth = lineWidth

        styler?(border)
    }
}
