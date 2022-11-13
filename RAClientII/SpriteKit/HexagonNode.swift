//
//  HexagonNode.swift
//  Client
//
//  Created by Eric Russell on 4/11/22.
//

import SpriteKit
import OrderedCollections
import SwiftUI

class HexagonNode: SKShapeNode {
    var hexagon: MappedHexagon
    
    var outerRadius: CGFloat
    var innerRadius: CGFloat
    var backgroundAdorner: SKLabelNode
    var backgroundImage: SKSpriteNode
    
    init(at coordinates: (x: Int, y: Int), hexagon: MappedHexagon, radius: CGFloat) {
        self.hexagon = hexagon
        self.outerRadius = radius
        self.innerRadius = hexagon.topology.innerRadius
        self.backgroundAdorner = SKLabelNode()
        self.backgroundImage = SKSpriteNode()

        super.init()
        
        setupHexagonPerimeterPath(at: coordinates)
        setupBackgroundAdorner()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBackground(text: String, with color: UIColor? = nil) {
        self.backgroundAdorner.fontColor = UIColor(white: 1.0, alpha: 0.3)
        self.backgroundAdorner.text = text
       
        self.backgroundAdorner.fontSize = pickFontSize(for: text)
        
        self.backgroundImage.isHidden = true
    }
    
    func setBackgroundImage(imageNamed imageName: String) {
        let image = UIImage(systemName: imageName)
        guard let image = image else { return }
        image.withRenderingMode(.alwaysTemplate)
        let coloredImage = UIImage.coloredImage(image: image, color: UIColor(white: 1.0, alpha: 0.3))!
        let texture = SKTexture(image: coloredImage)

        self.backgroundImage.texture = texture
        self.backgroundImage.color = .white
        self.backgroundImage.colorBlendFactor = 0.0
        self.backgroundImage.isHidden = false
        self.backgroundAdorner.text = ""
    }
    
    private func pickFontSize(for text: String) -> CGFloat {
        switch text.count {
        case 3..<4:
            return Constants.backgroundAdornerAlternateFontSize
        case 4...:
            return Constants.backgroundAdornerSecondAlternateFontSize
        default:
            return Constants.backgroundAdornerNormalFontSize
        }
    }
    
    func clearBackgroundImage() {
        self.backgroundImage.isHidden = true
    }
    
    private func setupHexagonPerimeterPath(at coordinates: (x:Int, y: Int)) {
        let path = CGMutablePath()
        
        var vertices = hexagon.topology.vertices(origin: CGPoint.zero, of: outerRadius)
        
        // close the path
        vertices.append(vertices.first!)
        
        vertices = vertices.map { v in CGPoint(x: v.x, y: -v.y) }
        
        path.addLines(between: vertices)
        
        self.lineWidth = 0
        self.path = path
    }
    
    private func setupBackgroundAdorner() {
        self.backgroundAdorner.verticalAlignmentMode = .center
        self.backgroundAdorner.fontName = "Helvetica"
        self.backgroundAdorner.fontSize =  Constants.backgroundAdornerNormalFontSize
        addChild(self.backgroundAdorner)
        
        addChild(self.backgroundImage)
        self.backgroundImage.size = CGSize(width: 30, height: 30)
    }
}

