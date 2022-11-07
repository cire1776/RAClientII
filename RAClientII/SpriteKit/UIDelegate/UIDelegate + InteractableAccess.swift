//
//  UIDelegate + FacilityAccess.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/1/22.
//

import SpriteKit
import GameplayKit
import SwiftUI

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
    
    func selectFacility(at position: CGPoint, for character: Character.Slice)  {
        let facility = closestInteractable(to: position) as! Facility
        self.selectedFacility = facility
        
        var renderer: MenuRenderer? = nil
        
        renderer = character.occupied ? FacilityExitRenderer() : FacilityMenuRenderer(for: facility)
        
        if let renderer = renderer {
            self.displayedMenu.openMenu(in: scene, focusedAt: position, renderedBy: renderer)
        } else {
            print("renderer not found.")
        }
    }
    
    func checkToCancelOperation(at position: CGPoint) {
        self.displayedMenu.openMenu(in: scene, focusedAt: position, renderedBy: FacilityExitRenderer())
    }
    
    func checkForDroppedItemPickup(_ droppedItem: DroppedItem, at destination: CGPoint) {
        self.displayedMenu.openMenu(in: scene, focusedAt: destination, renderedBy: DroppedItemPickupRenderer(droppedItem: droppedItem))
    }
    
    func selectCharacter(at position: CGPoint, by character: Character.Slice)  {
        let marker = closestInteractable(to: position, excludingPlayer: true) as! Character.Marker
        let selectedCharacter = (marker.character!.slice)
        
        var renderer: MenuRenderer? = nil
        
        switch selectedCharacter.type {
        case .npc:
            renderer = NonPlayerCharacterRenderer(for: selectedCharacter)
        case .character:
            renderer = CharacterRenderer(for: selectedCharacter)
        case .player:
            break
        }
        
        if let renderer = renderer {
            self.displayedMenu.openMenu(in: scene, focusedAt: position, renderedBy: renderer)
        } else {
            print("renderer not found.")
        }
    }
}
