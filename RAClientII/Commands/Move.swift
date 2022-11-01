//
//  Move.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/28/22.
//

import CoreGraphics

extension Command {
    static func Move(characterNode: CharacterNode, venuePosition: VenuePosition) {
        Task {
            await queue.push((.addWaypoint(destination: venuePosition, duration: 100), nil))
        }
        
        let gameScene = characterNode.gameScene
        let converter = gameScene.hexagonMapNode.convert(position:)
        
        let priorPosition = characterNode.locality.lastDestination ?? characterNode.character.locality.position
        
        let travelTicks = priorPosition.calculateTravelTicks(to: venuePosition, at: 1.25, converter: converter)
        
        _ = characterNode.locality.addWaypoint(to: venuePosition, at: Game.game.tick, for: travelTicks)
        
        characterNode.locality.type = .predictive
        
         if characterNode.locality.isOnLastWaypoint {
            characterNode.setFacing(venuePosition)
            characterNode.movementStarted()
        }
    }
}
