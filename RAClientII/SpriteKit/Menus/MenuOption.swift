//
//  MenuOption.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/6/22.
//

import SpriteKit

protocol MenuOption: SKNode {
    func execute()
}

class SimpleMenuOption: SKNode, MenuOption {
    var text: String {
        willSet {
            self.label.removeFromParent()
            self.label = SKLabelNode(text: newValue)
            formatLabel()
        }
    }
    var label: SKLabelNode
    var symbol: SKSpriteNode?
    var border: SKShapeNode
    var color: UIColor
    
    let action: ()->()
    
    init(text: String, symbolName: String? = nil, color: UIColor? = nil, action: @escaping ()->()) {
        self.text = text
        self.action = action
        self.label = SKLabelNode(text: text)
        self.border = SKShapeNode()
        self.color = color ?? UIColor.systemBlue
        super.init()
        
        layout(symbolName: symbolName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout(symbolName: String?) {
        if let symbolName = symbolName {
            var image = UIImage(systemName: symbolName)!
            
            image = UIImage.coloredImage(image: image, color: self.color)!
            
            let texture = SKTexture(image: image)
            let symbol = SKSpriteNode(texture: texture)
            symbol.size = CGSize(width: 5, height: 5)
            symbol.position = CGPoint(x: self.label.frame.width / 5, y: 4)
            
            symbol.color = self.color
            symbol.colorBlendFactor = 0
            
            self.label.position = self.label.position - CGPoint(x: 5, y: 0)
            
            self.symbol = symbol
           
            self.label.addChild(symbol)
        } else {
            self.symbol = nil
        }
        
        formatLabel()
    }
    
    func formatLabel() {
        self.label.fontSize = 9
        self.label.fontColor = self.color
        self.label.fontName = "Helvetica"
        self.addChild(self.label)
    }
    
    func execute() {
        action()
    }
}

class SubMenuOption: SKNode, MenuOption {
    let menuTree: MenuTree
    let label: SKLabelNode
    var symbol: SKSpriteNode?
    let renderer: MenuRenderer
    
    init(text: String, renderer: MenuRenderer, menuTree: MenuTree) {
        self.menuTree = menuTree
        self.label = SKLabelNode(text: text)
        self.symbol = nil
        self.renderer = renderer
        
        super.init()
        
        self.layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        self.label.fontSize = 9
        self.label.fontColor = .systemBlue
        self.label.fontName = "Helvetica"
        self.addChild(self.label)
        
        let symbolName = "arrowtriangle.right.fill"
        
        var image = UIImage(systemName: symbolName)!
        
        image = UIImage.coloredImage(image: image, color: .systemBlue)!
        
        let texture = SKTexture(image: image)
        let symbol = SKSpriteNode(texture: texture)
        symbol.size = CGSize(width: 5, height: 5)
        symbol.position = CGPoint(x: self.label.calculateAccumulatedFrame().width - 17 , y: 4)
        
        symbol.color = .systemBlue
        symbol.colorBlendFactor = 0
        
        self.label.position = self.label.position - CGPoint(x: 5, y: 0)
        
        self.symbol = symbol
        
        self.label.addChild(symbol)
    }
    
    func execute() {
        menuTree.openSubmenu(renderer: renderer)
    }
}
