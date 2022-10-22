//
//  DialogueNode.swift
//  OldRAClient
//
//  Created by Eric Russell on 6/3/22.
//

import Foundation
import SpriteKit

class DialogueNode: SKNode {
    var interaction: Interaction
    let character: Character

    var uiDelegate: UIDelegate
    var responseLabels = [Dialogue.Instruction : SKLabelNode]()
   
    init(interaction: Interaction, for character: Character) {
        self.interaction = interaction
        self.character = character
        
        self.uiDelegate = UIDelegate()
        
        super.init()
        
        self.uiDelegate = GameClient.gameScene.uiDelegate
        self.uiDelegate.dialogueNode = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleClick(at destination: CGPoint) {}
    
    func dismiss() {
        uiDelegate.dialogueNode = nil
        self.removeFromParent()
        interaction.dismiss(for: character)
    }
}

class DialogueResponseNode: DialogueNode {
    let label: SKLabelNode
    let background: SKShapeNode
    let dialogue: Dialogue
    
    var text: String {
        get {
            label.text ?? ""
        }
        
        set {
            label.text = newValue
        }
    }
    
    override init(interaction: Interaction, for character: Character) {
        dialogue = interaction as! Dialogue
        
        var label = SKLabelNode(text:"")
        
        label.text = dialogue.line
        
        label.fontName = "Helvetica"
        label.verticalAlignmentMode = .center
        label.position.y += 300
        label.fontSize = 100
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = 1_500
        label.fontColor = .black

        self.label = label
        self.background = SKShapeNode(rectOf: CGSize(width: 2_000, height: 1_500),cornerRadius: 5)

        super.init(interaction: interaction, for: character)
        
        background.addChild(label)

        background.fillColor = .init(white: 0.88, alpha: 0.7)
        
        self.addChild(background)
        
        var lineNumber = self.children.count
        
        for (response, instruction) in dialogue.responses {
            label = SKLabelNode(text: response)
            background.addChild(label)
            
            label.fontName = "Helvetica"
            label.verticalAlignmentMode = .center
            label.fontSize = 100
            label.fontColor = .black
            label.position.y = -CGFloat(lineNumber * 200) + 100
            lineNumber += 1
            responseLabels[instruction] = label
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func handleClick(at destination: CGPoint) {
        for (instruction, responseLabel) in self.responseLabels {
            if responseLabel.contains(destination) {
                dialogue.process(instruction, for: Quest.character)
            }
        }
    }
}

class MonologueNode: DialogueNode {
    let monologue: Monologue
    
    let label: SKLabelNode
    let background: SKShapeNode
    
    let advanceButton: SKSpriteNode
    let buttonName = "advance button"
    
    init(interaction: Interaction, text: String, for character: Character) {
        self.monologue = interaction as! Monologue
        
        let label = SKLabelNode(text:"")
        
        label.text = text
        
        label.fontName = "Helvetica"
        label.verticalAlignmentMode = .center
        label.fontSize = 100
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = 1_500
        label.fontColor = .black
        
        self.label = label
        
        self.background = SKShapeNode(rectOf: CGSize(width: 2_000, height: 1_500),cornerRadius: 5)
        
        var uiImage = UIImage(systemName: monologue
            .isDone ? "arrowshape.turn.up.backward.circle.fill" : "arrow.right.circle.fill")!
        uiImage = uiImage.withTintColor(.blue,renderingMode: .alwaysTemplate)
        
        let texture = SKTexture(image: uiImage)
        self.advanceButton = SKSpriteNode(texture: texture)
        
        super.init(interaction: interaction, for: character)
        
        self.advanceButton.setScale(7.5)
        self.advanceButton.position = CGPoint(x: 600, y: -500)
        
        background.addChild(label)
        background.addChild(advanceButton)
        
        background.fillColor = .init(white: 0.88, alpha: 0.7)
        
        self.addChild(background)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func handleClick(at destination: CGPoint) {
        if advanceButton.contains(destination) {
            monologue.advance(for: character)
        }
    }
}
