//
//  CharacterNode.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/24/22.
//

import SpriteKit
import Combine

class CharacterNode: SKSpriteNode, FaceableNode, Moveable, Updating, MarkerUser {
    static func setup(scene: GameScene, insertions: [Character.ID], deletions: [Character.ID]) {
        for character in deletions {
            if let node = scene.hexagonMapNode.childNode(withName: character)  as? CharacterNode {
                if let index = scene.characterNodes.firstIndex(of: node) {
                    scene.characterNodes.remove(at: index)
                }
                node.removeFromParent()
            }
        }
        
        for characterID in insertions {
            self.performInsertion(scene: scene, characterID: characterID)
        }
    }
    
    private static func performInsertion(scene: GameScene, characterID: Character.ID) {
        guard let expression = try? (scene.venue![.character, characterID] as! Character.Expression)
        else {
            print("***Unable to find character:", characterID)
            return
        }
        
        let characterData = expression.slice
        
        let playerType: Character.Class = characterData.id == scene.venue.playerCharacterID ?
            .player :
        characterData.type

        let characterNode: CharacterNode
        let updating: Bool
        if let node = scene.hexagonMapNode.childNode(withName: characterID) as? CharacterNode {
            print("$$$updating")
            updating = true
            characterNode = node
        } else {
            updating = false
            characterNode = CharacterNode(character: characterData, as: playerType)
            print("$$$Inserting")
        }
            
        characterNode.name = characterData.id
        
        if playerType == .player {
            scene.playerNode = characterNode
            Command.player = scene.venue!.playerCharacter.slice
        }
        
        characterNode.setFacing(to: characterData.facing, for: scene.orientation)
        
        let position = scene.hexagonMapNode.convert(position: characterData.locality.position)
        characterNode.position = position
        
        if !updating {
            characterNode.zPosition = Constants.playerLevel
            characterNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 5))
            characterNode.physicsBody?.collisionBitMask = 0xFFFE
            characterNode.physicsBody?.categoryBitMask = 0x0001
            characterNode.physicsBody?.isDynamic = true
            scene.hexagonMapNode.addChild(characterNode)
            scene.characterNodes.append(characterNode)
        }
    }
    
    static var characterColors:[Character.Class : SKColor] = [
        .player    : .blue,
        .character : .black,
        .npc       : .orange
    ]
  
    var ID: String = UUID().uuidString
    var type: Character.Class
    var character: Character.Slice
    
    var movementAction: SKAction? = nil
    var movementLine: SKNode? = nil
    
    var locality: Locality
    var currentArrivalTick: UInt64? = nil
    
    var currentRotation: CGFloat = 0
    
    var isPlayer: Bool {
        character.type == .player
    }
    
    var isMoving: Bool {
        locality.isMoving
    }
    
    var gameScene: GameScene {
        self.scene as! GameScene
    }

    init(character: Character.Slice, as type: Character.Class = .character) {
        self.type = type
        self.character = character
        self.locality = character.locality
        
        let texture = SKTexture(imageNamed: "character.png")
        let color = Self.characterColors[type] ?? .white
        
        let size = CGSize(width: 10 , height: 5)
        
        super.init(texture: texture, color: color, size: size)
        
        self.colorBlendFactor = 1.0
        self.name = "character:player"
        
        subscribe()
        
        GameScene.updaters.append(update(_:))
        GameScene.updaters.append(movementUpdate(_:))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func subscribe() {
        var subscription = self.character.$facing.sink(receiveValue: { notification in
            self.setFacing(to: notification, for: .point)
        })
        
        allSubscriptions.insert(subscription)
        
        subscription =  self.character.$locality
                            .debounce(for: 0.01, scheduler: RunLoop.main)
                            .receive(on: RunLoop.main)
                            .sink(receiveValue: { notification in
            if self.scene != nil,
               self.gameScene.playerNode != nil,
               notification.isPositionAuthoritative {
                print("received character.locality update:",self.character.id)
                
                let wasAlreadyMoving = self.isMoving
                self.moveAuthoritatively(notification)
                
                if !wasAlreadyMoving {
                    self.movementStarted()
                }
            }
        })
        
        allSubscriptions.insert(subscription)
    }
    
    func updateFacing(notification:Any) {
        if let param = notification as? Facing {
            self.setFacing(to: param, for: .point)
        }
    }
    
    func update(_ currentTime: TimeInterval) {
        self.physicsBody?.angularVelocity = .zero
    }
}
