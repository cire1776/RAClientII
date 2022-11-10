//
//  CharacterNode + Moveable.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/29/22.
//

import SpriteKit

//temp global
var isFirst = false

extension CharacterNode {
    func moveAuthoritatively(_ locality: Locality) {
        cancelAnimations()
        sortWaypoints()
        
        self.locality.updateFromAuthoritative(locality)
        
        if locality.isMoving {
            if isPlayer {
                eraseWaypoints()
                drawWaypoints()
            }
            setCurrentFacing()
            createAnimations()
        } else {
            updatePosition()
        }
    }
    
    private func cancelAnimations() {
        self.removeAction(forKey: Constants.movementActionKey)
    }
    
    private func sortWaypoints() {
        self.locality.sortWaypoints()
    }
    
    private func drawWaypoints() {
        guard isPlayer else { return }
        let waypoints = self.locality.waypoints.sorted { $0.arrivalTick > $1.arrivalTick}
        
        var previousWaypoint: Waypoint? = nil

        for waypoint in waypoints {
            let currentWaypoint = waypoint == self.locality.waypoints.first!
            
            let destination = (self.parent as! HexagonMapNode).convert(position: waypoint.destination)
            
            drawMarker(at: destination, waypoint.destination.hex, CGPoint(x: waypoint.destination.x, y: waypoint.destination.y))
            
            if currentWaypoint {
                updateMarker()
            }
            
            //            drawMarker(for: waypoint, is: currentWaypoint)
            drawLine(for: waypoint, previousWaypoint: previousWaypoint)
            
            previousWaypoint = waypoint
        }
    }
    
    private func drawLine(for waypoint: Waypoint, previousWaypoint: Waypoint?) {
        let venuePosition = waypoint.destination
        let destination = gameScene.hexagonMapNode.convert(position: venuePosition)

        let source: CGPoint
        if let previousWaypoint = previousWaypoint {
            source = gameScene.hexagonMapNode.convert(position: previousWaypoint.destination)
        } else {
            source = gameScene.playerNode.position
        }

        let line = gameScene.markerLayer.drawDashedLine(from: source, to: destination, pattern: [10,5]) { [weak self] line in
            self?.styleDashedLine(line)
            line.strokeColor = .red
            line.name = self?.gameScene.markerName(for: venuePosition, as: "line")
        }
        
        if previousWaypoint == nil {
            self.movementLine = line
        }
    }
    
    private func setCurrentFacing() {
        guard let venuePosition = self.locality.currentDestination else { return }
        let destination = gameScene.hexagonMapNode.convert(position: venuePosition)
        
        setFacing(towards: destination)
    }
    
    private func eraseWaypoints() {
        gameScene.clearAllMarkers()
    }
    
    private func createAnimations() {
        let action = SKAction.customAction(withDuration: 1.0) { [weak self] _, _ in
            if self!.isMoving && self!.isPlayer {
                let destination = self!.gameScene.hexagonMapNode.convert(position: self!.locality.currentDestination!)

                self?.movementLine?.removeFromParent()
                
                let movementLine = self?.gameScene.markerLayer.drawDashedLine(from: self?.position ?? .zero, to: destination, pattern: [10, 5]) { [weak self] line in
                    self?.styleDashedLine(line)
                    line.name = "movementLine"
                }

                self?.movementLine = movementLine!
            }
        }
        let foreverAction = SKAction.repeatForever(action)
        self.movementAction = foreverAction
        self.run(foreverAction, withKey: Constants.movementActionKey)
    }
    
    private func updatePosition() {
        self.physicsBody?.velocity = CGVector.zero
        gameScene.uiDelegate.movementComplete(isPlayer: isPlayer)
    }
    
    private func styleMarker(_ node: SKNode, isCurrentMarker: Bool = false) {
        (node  as! SKShapeNode).fillColor = markerColor(isCurrent: isCurrentMarker)
        node.name = Constants.currentWaypointName
    }
    
    private func createStyledMarker(isCurrentMarker: Bool = false) -> SKNode {
        let node = SKShapeNode(circleOfRadius: 5)
        styleMarker(node,isCurrentMarker: isCurrentMarker)
        return node
    }
    
    func movementUpdate(_ currentTime: TimeInterval) async {
        guard let venuePosition = self.locality.currentDestination else { return }
        
        let destination = gameScene.hexagonMapNode.convert(position: venuePosition)

        if self.isCloseEnough(destination) {
            await self.endWaypoint()
        } else {
            await self.continueAlongWaypoint(to: destination)
        }
    }
    
    func addWaypoint(to destination: CGPoint) {
        let hexagonMapNode = gameScene.hexagonMapNode!
       
        let destination = gameScene.convertPoint(fromView: destination, to: hexagonMapNode)
        
        guard let (coordinates, position) = hexagonMapNode.findHex(at: destination) else  { return }
        
        if isPlayer {
            drawMarker(at: destination, coordinates, position)
            drawLine(to: destination, coordinates, position)
        }
        
        Task {
            await Command.Move(characterNode: self, venuePosition: VenuePosition(hex: (coordinates.x, coordinates.y), x: Int(position.x), y: Int(position.y)))
        }
    }
    
    private func styleDashedLine(_ line: SKShapeNode) {
        line.strokeColor = .lightGray
        line.lineWidth = 3
        line.zPosition = Constants.lineLevel
    }
    
    func movementStarted(at currentTick: UInt64) async {
        self.locality = self.character.locality

        // during movement position is predictive,
        // except for brief moments at the end of
        // a waypoint.
        self.locality.type = .predictive
        
        guard self.isMoving else { return }
        
        self.currentArrivalTick = self.locality.waypoints.first!.arrivalTick + currentTick
       
        print("currentArrivalTick:", currentArrivalTick!, "currentTick:", currentTick)
        
        if self.isPlayer {
            updateMarker()
            updateLine()
        }
        
        createAnimations()
    }
    
       
    private func drawMarker(at destination: CGPoint, _ coordinates: Coordinates, _ position: CGPoint) {
        let venuePosition = VenuePosition(coordinates,position)
        
        gameScene.displayMarker(named: gameScene.markerName(for: venuePosition), at: destination) { position in
            return createStyledMarker()
        }
    }
    
    private func drawLine(to destination: CGPoint, _ coordinates: Coordinates, _ position: CGPoint) {
        // draw line
        let priorVenuePosition = self.locality.lastDestination ??
        gameScene.hexagonMapNode.convert(point: self.position)
        
        let priorDestination = self.gameScene.hexagonMapNode.convert(position: priorVenuePosition)
        
        let destinationWaypoint = VenuePosition(coordinates, position)
        
        let lineName = gameScene.markerName(for: destinationWaypoint, as: "line")
        
        if gameScene.markerLayer.childNode(withName: lineName) == nil {
            _ = gameScene.markerLayer.drawDashedLine(from: priorDestination, to: destination, pattern: [10,5]) { [weak self] line in
                self?.styleDashedLine(line)
                line.strokeColor = .blue
                
                line.name = lineName
            }
        }
    }

    fileprivate func updateLine() {
        guard let venuePosition = self.locality.currentDestination else { return }
        
        if let node = gameScene.markerLayer.childNode(withName: gameScene.markerName(for: venuePosition, as: "line")) {
            node.removeFromParent()
        } else {
            print("waypoint line not found:", venuePosition)
            
            if !gameScene.markerLayer.children.isEmpty {
                for child in gameScene.markerLayer.children {
                    print("name:",child.name ?? "Unnamed")
                }
            } else {
                print("no children found.")
            }
        }
    }
    
    private func updateMarker() {
        guard let venuePosition = self.locality.currentDestination else { return }
        
        let markerName = gameScene.markerName(for: venuePosition)
        
        if let node = gameScene.markerLayer.childNode(withName: markerName) {
            styleMarker(node, isCurrentMarker: true)
        } else if let node = gameScene.markerLayer.childNode(withName: Constants.currentWaypointName) {
            styleMarker(node, isCurrentMarker: true)
        } else {
            print("next waypoint not found")
        }
    }
    
    private func isCloseEnough(_ destination: CGPoint) -> Bool {
        let distance = self.position - destination
        return abs(distance.magnitude) < 2
    }
    
    private func endWaypoint() async {
        if isFirst {
            isFirst = false
        }
        let gameScene = (self.scene as! GameScene)
        
        let currentTick = await Game.game.clock.tick
        
        print("reached waypoint at tick:", currentTick)
        
        self.physicsBody?.velocity = CGVector.zero
        gameScene.uiDelegate.movementComplete(isPlayer: isPlayer)
        
        self.locality.completeCurrentWaypoint()
        
        if self.locality.isMoving {
            await self.movementStarted(at: currentTick)
            setCurrentFacing()
        } else {
            gameScene.markerLayer.removeFromParent()
        }
    }
    
    private func continueAlongWaypoint(to destination: CGPoint) async {
        let difference = destination - self.position

        var newVelocity = CGVector(dx: difference.x, dy: difference.y).normalized
        
        let timeLeft: UInt64
        let currentTick = await Game.game.clock.tick
        
        if self.currentArrivalTick ?? 0 > currentTick {
            timeLeft = self.currentArrivalTick! - currentTick

            newVelocity = newVelocity * (18 * difference.magnitude / CGFloat(timeLeft))

            self.physicsBody?.velocity = newVelocity
        } else {
            timeLeft = 0
            self.position = destination
        }
    }
}
