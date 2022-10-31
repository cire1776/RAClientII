//
//  UIDelegate + Movement.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/30/22.
//

import SpriteKit

extension UIDelegate {
    func setupMovement(_ view: SKView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(Self.pan(sender:)))
        view.addGestureRecognizer(pan)
    }
   
    func movementClick(sender: UITapGestureRecognizer) {
        guard sender.numberOfTouches == 1 else { return }
        
        let destination = sender.location(in: scene.view)

        switch sender.state {
        case .began, .changed:
            guard sender.numberOfTouches == 1 else { return }
            handleMovementGestures(to: destination)
        case .ended:
            handleMovementGestureEnded(to: destination)
        default:
            break
        }
    }
    
    @objc
    private func pan(sender: UIPanGestureRecognizer) {
        if sender.numberOfTouches == 2 || screenDragInProgress {
            switch sender.state {
            case .began, .changed:
                screenDragInProgress = true
                handleScreenDrag(sender: sender)
            case .ended:
                screenDragInProgress = false
            default:
                screenDragInProgress = false
            }
        } else {
            guard sender.numberOfTouches < 2,
                  let character = scene.playerNode?.character,
                  !character.occupied else { return }
            
            let destination = sender.location(in: scene.view)
            
            switch sender.state {
            case .began, .changed:
                handleMovementGestures(to: destination)
            case .ended:
                handleMovementGestureEnded(to: destination)
            default:
                break
            }
        }
    }
    
    func handleScreenDrag(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: scene.view)
        let scale = scene.childNode(withName: "HexagonMapNode")?.xScale ?? 1.0
        if sender.state == .changed {
            if lastDragLocation != nil {
                scene.camera?.physicsBody?.applyImpulse(CGVector(dx: -sender.velocity(in: scene.view).x * scale, dy: sender.velocity(in: scene.view).y * scale))
            }
            
            self.lastDragLocation = translation
        } else if sender.state == .ended {
            lastDragLocation = nil
        }
    }
    
    func handleMovementGestures(to destination: CGPoint) {
        var destination = scene.convertPoint(fromView: destination)
        destination = scene.convert(destination, to: hexagonMapNode)
        
        if let line = scene.markerLayer.childNode(withName: "designatorLine") {
            line.removeFromParent()
        } else {
            print("designatorLine not found")
        }
        
        guard self.hexagonMapNode.contains(point: destination) else { return }
        
        let lineOrigin: CGPoint
        
        if playerNode.isMoving {
            let venuePosition = playerNode.locality.lastDestination!
            lineOrigin = self.hexagonMapNode.convert(position: venuePosition)
        } else {
            lineOrigin = playerNode.position
        }
        
        _ = scene.markerLayer.drawLine(
            from: lineOrigin,
            to: destination
        ) { line in
            line.strokeColor = .lightGray
            line.lineWidth = 3
            line.zPosition = Constants.lineLevel
            line.name = "designatorLine"
        }
    }
    
    func handleMovementGestureEnded(to destination: CGPoint) {
        if let line = scene.markerLayer.childNode(withName: "designatorLine") {
            line.removeFromParent()
        } else {
            print("designatorLine not found")
        }
        playerNode.addWaypoint(to: destination)
    }
    
    func movementComplete(isPlayer: Bool) {
        
        if isPlayer {
            scene.clearMarker(named: Constants.currentWaypointName)

            if !playerNode.isMoving {
                scene.removeAction(forKey: Constants.movementActionKey)
                self.movementLine?.removeFromParent()
                self.movementLine = nil
            }
        }
    }
}
