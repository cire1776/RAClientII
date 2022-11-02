//
//  UIDelegate + Taps.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/2/22.
//

import SpriteKit
import GameKit

extension UIDelegate {
    func setupTaps(_ view: SKView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(Self.taps(sender:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc
    private func taps(sender: UITapGestureRecognizer) {
        guard sender.numberOfTouches == 1,
              let character = scene.playerNode?.character else { return }
        
        if sender.state == .ended {
            var destination = sender.location(in: scene.view)
            destination = scene.convertPoint(fromView: destination)
            destination = scene.convert(destination, to: hexagonMapNode)
            
            if self.dialogueNode != nil {
//                handleDialogueClick(at: destination)
            } else if self.displayedMenu.isActive {
//                handleMenuClick(at: destination, for: self.displayedMenu)
            } else if self.debugMenu.isActive {
//                handleMenuClick(at: destination, for: self.debugMenu)
            } else if isPlayer(near: destination) && character.occupied {
//                checkToCancelOperation(at: destination)
            } else if isPlayer(near: destination) &&
                      areInteractables(near: destination) {
                let interactable = closestInteractable(to: destination,excludingPlayer: true)
                
                if let facility = interactable as? Facility {
                    checkFacilityInteraction(facility, at: destination, by: character)
                } else if let _ = interactable as? Character.Marker {
//                    selectCharacter(at: destination, by: character)
                } else if let _ = interactable as? DroppedItem {
//                    checkForDroppedItemPickup(droppedItem,at: destination)
                }
            } else {
                guard !character.occupied else { return }
                movementClick(sender: sender)
            }
        }
    }
    
    func closestInteractable(to destination: CGPoint, excludingPlayer: Bool = false) -> Interactable? {
        var area = CGRect(origin: destination, dx: Constants.InteractableAccessRange, dy: Constants.InteractableAccessRange)
        area = area.offsetBy(dx: -Constants.InteractableAccessRange, dy: -Constants.InteractableAccessRange)

        let quad = GKQuad(quadMin: vector_float2(x: Float(area.minX), y: Float(area.minY)), quadMax: vector_float2(x: Float(area.maxX), y: Float(area.maxY)))
        
        let possibles = GameClient.gameClient.venue.interactablesMap.elements(in: quad)
        
        let converter = self.scene.hexagonMapNode.convert(position:)
        
        let interactables = possibles.sorted(by: {
            let lhs = $0 as! Interactable, rhs = $1 as! Interactable
            
            return lhs.position.distance(to: destination, converter: converter) < rhs.position.distance(to: destination, converter: converter)
        })
        .map { $0 as! Interactable}
        
        if excludingPlayer && interactables[0].type == .player {
            let newPossibility = interactables[1]
            
            if newPossibility.position.distance(to: destination, converter: converter) <= Constants.InteractableAccessRange {
                return newPossibility
            }

            return nil
        }
        return interactables[0]
    }
    
    func checkFacilityInteraction(_ facility: Facility, at destination: CGPoint, by character: Character.Slice ) {
        if character.occupied {
//            checkToCancelOperation(at: destination)
        } else {
//            selectFacility(at: destination, for: character)
        }
    }
}

extension UIDelegate {
    func isPlayer(near position: CGPoint) -> Bool {
        let offset = scene.playerNode.position - position
        return abs(offset.x) <= Constants.InteractableAccessRange && abs(offset.y) <= Constants.InteractableAccessRange
    }
    
    func areInteractables(near position: CGPoint) -> Bool {
        var area = CGRect(origin: position, dx: Constants.InteractableAccessRange, dy: Constants.InteractableAccessRange)
        area = area.offsetBy(dx: -Constants.InteractableAccessRange, dy: -Constants.InteractableAccessRange)
        
        let quad = GKQuad(quadMin: vector_float2(x: Float(area.minX), y: Float(area.minY)), quadMax: vector_float2(x: Float(area.maxX), y: Float(area.maxY)))

        let interactables = GameClient.gameClient.venue.interactablesMap.elements(in: quad)
        
        return !interactables.isEmpty
    }
}