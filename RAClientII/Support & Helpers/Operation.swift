//
//  Operation.swift
//  RAClientII
//
//  Created by Eric Russell on 11/4/22.
//

import Foundation

extension Constants {
    static let operationTag = "operation tag"
}

public struct Operation {
    let period: UInt64
    let startingTick: UInt64
    let skill: String
    let name: String
    let facilityID: Facility.ID?
    
    public init(period: UInt64, startingTick: UInt64, skill: String, name: String, facilityID: Facility.ID? = nil) {
        self.period = period
        self.startingTick = startingTick
        self.skill = skill
        self.name = name
        self.facilityID = facilityID
        
        print("operation:", period, startingTick, skill, name, facilityID ?? "N/A")
    }
    
    public init?(from source: RABackend_OperationStatus) {
        guard source.period != 0 else { return nil }
        
        self.period = source.period
        self.startingTick = source.startingTick
        self.skill = source.skill
        self.name = source.name
        self.facilityID = source.facilityID.id
        
        print("operation:", period, startingTick, skill, name, facilityID ?? "N/A")
    }
   
    public func begin(for character: Character.Slice, actionRegistry: ActionRegisterable) {
        character.operation = self
        
        Task {
            let currentTick = await Game.game.clock.tick
            
            let remainingTime = self.period - (currentTick - self.startingTick) % (self.period * Constants.numberOfTicksPerSecond) / Constants.numberOfTicksPerSecond
            
            await MainActor.run {
                let hexCoordinates = character.locality.position.hex
                let hex = GameClient.gameScene.hexagonMapNode.findHexNode(at: hexCoordinates)
                
                Task {
                    await actionRegistry.addSeconds(id: Constants.operationTag) {_ in
                        let currentTick = await Game.game.clock.tick
                        let remainingTime = self.period - (currentTick - self.startingTick) % (self.period * Constants.numberOfTicksPerSecond) / Constants.numberOfTicksPerSecond
                        
                        hex.setBackground(text: String(remainingTime))
                    }
                }
            }
        }
    }
    
    public func cancel(for character: Character.Slice, actionRegistry: ActionRegisterable) {
        character.operation = nil

        Task {
            let hexCoordinates = character.locality.position.hex
            let hex = await GameClient.gameScene.hexagonMapNode.findHexNode(at: hexCoordinates)

            await actionRegistry.clear(id: Constants.operationTag)

            await MainActor.run {
                hex.setBackground(text: "")
            }
        }
    }
}
