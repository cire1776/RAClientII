//
//  Move.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/28/22.
//

import CoreGraphics

extension Command {
    static func Move(characterNode: CharacterNode, venuePosition: VenuePosition) {
        let gameScene = characterNode.gameScene
        let converter = gameScene.hexagonMapNode.convert(position:)
        
        let priorPosition = characterNode.locality.lastDestination ?? characterNode.character.locality.position
        
        let travelTicks = priorPosition.calculateTravelTicks(to: venuePosition, at: 1.25, converter: converter)
        
        characterNode.locality.startingTick = characterNode.locality.startingTick ?? gameScene.gameClient.tick
        
        let waypoint = characterNode.locality.addWaypoint(to: venuePosition, at: gameScene.gameClient.tick, for: travelTicks)
        
        characterNode.locality.type = .predictive

//        Command.server.addWaypoint(to: venuePosition, with: characterNode.locality.waypoints, using: waypoint.id)
        
         if characterNode.locality.isOnLastWaypoint {
            characterNode.setFacing(venuePosition)
            characterNode.movementStarted()
        }
    }
}
