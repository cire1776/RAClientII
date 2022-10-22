//
//  MenuNode.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/2/22.
//

import SpriteKit
import OrderedCollections
import SwiftUI

class MenuNode: SKNode {
    let focusedAt: CGPoint
    let renderer: MenuRenderer
    let menuTree: MenuTree
   
    let content: Container
    var background: SKShapeNode
    
    init(focusedAt: CGPoint, renderedBy renderer: MenuRenderer, in menuTree: MenuTree) {
        self.focusedAt = focusedAt
        self.renderer = renderer
        self.menuTree = menuTree
        
        self.content = Container()
        self.background = SKShapeNode()
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layout() {
        // temporarily add a background to the scene so that scene is
        // available during rendering.
        let tempBackground = SKShapeNode()
        tempBackground.addChild(content)
        self.addChild(tempBackground)
        
        renderer.render(to: content, menuTree: self.menuTree)
        
        content.layout()
        
        let frame = content.calculateAccumulatedFrame().insetBy(dx: -5, dy: -10)
        self.background = SKShapeNode(rectOf: frame.size, cornerRadius: 5)
        self.background.fillColor = UIColor(white: 1.0, alpha: 0.4)
        
        self.background.position = self.focusedAt + CGPoint(x: frame.width / 2 + 10, y: 0)
        self.background.zPosition = Constants.adornerLevel
        self.content.removeFromParent()
        self.background.addChild(content)
        self.background.name = "Background"
        self.content.name = "Container"
        self.addChild(background)
        self.name = "Menu"
    }
}

class Container: SKNode {
    var title: String
    var options = SKNode()
    
    override init() {
        self.title = ""

        super.init()
        
        self.options.name = "Options"
        self.addChild(self.options)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func accept(menuOption: MenuOption) {
        self.options.addChild(menuOption)
    }
    
    func layout() {
        for (i, child) in options.children.enumerated() {
            child.position = CGPoint( x: 0, y: i * 15 )
        }
        
        options.position = CGPoint(x: 0, y: -options.calculateAccumulatedFrame().height / 2 - (options.children.count.isOdd ? 10 : 5))
        
        if self.title != "" {
            let title = SKLabelNode(text: title.capitalized)
            title.fontColor = .black
            title.fontSize = 9
            title.fontName = "Helvetica"
            title.position = CGPoint(x: 0, y: self.calculateAccumulatedFrame().height / 2)

            self.addChild(title)
        } else {
            options.position = options.position +
            CGPoint(x: 0, y: 10)
        }
    }
}
