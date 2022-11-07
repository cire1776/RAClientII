//
//  Move.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/28/22.
//

import CoreGraphics

extension Command {
    @MainActor
    static func Move(characterNode: CharacterNode, venuePosition: VenuePosition) async {
        await queue.push((.addWaypoint(destination: venuePosition, duration: 100), nil))
        
        let gameScene = characterNode.gameScene
        let converter = gameScene.hexagonMapNode.convert(position:)
        
        let lastDestination = characterNode.locality.lastDestination
        let characterPosition = characterNode.character.locality.position
        let priorPosition =  lastDestination ?? characterPosition
        
        let travelTicks = priorPosition.calculateTravelTicks(to: venuePosition, at: 1.25, converter: converter)
       
        let currentTick = await Game.game.clock.tick
        _ = characterNode.locality.addWaypoint(to: venuePosition, at: currentTick, for: travelTicks)
        
        characterNode.locality.type = .predictive
        
         if characterNode.locality.isOnLastWaypoint {
            characterNode.setFacing(venuePosition)
             await characterNode.movementStarted(at: currentTick)
        }
    }
}
