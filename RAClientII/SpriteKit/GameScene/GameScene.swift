//
//  GameScene.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/22/22.
//

import Foundation
import SpriteKit
import SwiftUI
import UIKit

class GameScene : SKScene, ObservableObject, MarkerAdornable {
    static var updaters = [Updater]()
    
    var gameClient: GameClient!
    var venue: Venue! {
        gameClient.venue
    }
    
    var characters: Character.Characters! {
        gameClient.characters
    }
    
    var orientation: Hexagon.Orientation
    var region: Hexagon.Region<Geography.TerrainSpecifier>
    
    var uiDelegate: UIDelegate! = nil
    
    var hexagonMap: Hexagon.Map<Geography.TerrainSpecifier>? = nil
    var hexagonMapNode: HexagonMapNode! = nil

    var characterNodes = [CharacterNode]()
    var playerNode: CharacterNode! = nil
    
    var predictiveSignal = SKShapeNode(rectOf: CGSize(width: 100, height: 100))
    
    var minimap: UIImage? {
        guard let map = self.childNode(withName: "HexagonMapNode") else { return nil }
        
        return map.toImage()
    }

    override init(size: CGSize) {
        // temporarily set.  Needs to be reset during setup.
        self.orientation = .point
        self.region = Hexagon.Region<Geography.TerrainSpecifier>()
        
        super.init(size: size)
        
        self.uiDelegate = UIDelegate(scene: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
    }
    
    override func didMove(to view: SKView) {
    }
    
    override func didSimulatePhysics() {
    }
    
    override func update(_ currentTime: TimeInterval) {
//        view?.showsFPS = true
//        view?.showsPhysics = true
        
        for updater in Self.updaters {
            updater(currentTime)
        }
        
        if let playerNode = self.playerNode {
            self.predictiveSignal.fillColor = playerNode.locality.isAuthoritative ? .green : playerNode.locality.areWaypointsAuthoritative ? .yellow : .red
        }
    }
    
    func initialize() {
         uiDelegate.setup(view: self.view!)
        
        HexagonMapNode.setup(scene: self, radius: 100)

        subscribe()

        SKCameraNode.setup(scene: self)
        
        self.predictiveSignal.fillColor = .white
        self.predictiveSignal.position = CGPoint(x: -3131, y: -2226)
        self.predictiveSignal.zPosition = 1000
        
        self.camera!.addChild(self.predictiveSignal)
        
        self.uiDelegate.setupMovement(self.view!)
    }
    
    func subscribe() {
        let cancellable = venue.$characters
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { characters in
            let current = self.characterNodes.map({ $0.character.id })
            
            let characterIDs = Array(characters
                .map { $0.0 })
                                 
            let insertions = characterIDs
                .filter({ !current.contains($0) })
            
            let deletions = Array(current.filter({ !characterIDs.contains($0) }))
            
            CharacterNode.setup(scene: self, insertions: insertions, deletions: deletions)
        })
        allSubscriptions.insert(cancellable)
    }
    
    func setupScene() {
        self.region = self.gameClient.venue.region

        self.scaleMode = .aspectFill
        
        let hexMap = Hexagon.Map(
            region: self.region,
            diameter: 100,
            orientation: orientation
        )
        
        self.hexagonMap = hexMap
        
        self.backgroundColor = UIColor(red: 61/255, green: 72/255, blue: 73/255, alpha: 1.0)
        self.physicsWorld.gravity = .zero
    }
    
    func convertPoint(fromView point: CGPoint, to node: SKNode) -> CGPoint {
        var result = self.convertPoint(fromView: point)
        result = self.convert(result, to: node)
        return result
    }
}
