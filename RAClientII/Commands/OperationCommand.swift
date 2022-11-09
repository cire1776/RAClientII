//
//  Operation.swift
//  RAClientII
//
//  Created by Eric Russell on 11/4/22.
//

import Foundation

extension Command {
    static public func BeginOperation(operation: String, facilityID: Facility.ID) {
        Task {
            let command:(ClientCommand, ClientCommand?) = (.beginOperation(facility: facilityID, operation: operation.lowercased()), nil)
            await queue.push(command)
        }
    }
    
    static public func CancelWork(character: Character.Slice) {
        Task {
            let command:(ClientCommand, ClientCommand?) = (.cancelOperation, nil)
            character.operation?.cancel(for: character, actionRegistry: Game.game.clock)
            
            await queue.push(command)
        }
    }
}
