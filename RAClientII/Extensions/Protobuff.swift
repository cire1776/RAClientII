//
//  ProtoBuff.swift
//  RAClientII
//
//  Created by Eric Russell on 10/24/22.
//

import Foundation

public extension RABackend_Orientation {
    var toOrientation: Hexagon.Orientation {
        self == .point ? .point : .flat
    }
}

public extension RABackend_GameCommand {
    init(clientCommand: ClientCommand) {
        switch clientCommand {
        case .nop,.wait(_):
            break
        case .report:
            self.command = .report
        case .connect:
            self.command = .connect
            self.stringParam = ""
        case .close:
            self.command = .close
        case .beginOperation:
            self.command = .beginOperation
            guard case let .beginOperation(facilityID, operation) = clientCommand else { return }
            self.operation.facility.id = facilityID
            self.operation.operation = operation
        case .cancelOperation:
            self.command = .cancelOperation
        case .command:
            self.command = .command
        case .face(facing: let facing):
            self.command = .face
            self.facing = UInt64(facing)
        // addWaypoint is move and ignores the duration.
        case .addWaypoint(destination: let destination, duration: let duration):
            self.command = .addWaypoint
            self.addWaypointParams.position = RABackend_VenuePosition(position: destination)
            self.addWaypointParams.for = duration
        case .abortMovement:
            self.command = .abortMovement
        case .abortLastWaypoint:
            self.command = .abortLastWaypoint
        case .consume(itemID: let itemID):
            self.command = .consume
            self.itemID.id = itemID
        case .use(itemID: let itemID):
            self.command = .use
            self.itemID.id = itemID
        case .drop(itemID: let itemID):
            self.command = .drop
            self.itemID.id = itemID
        case .pickup(droppedItemID: let droppedItemID):
            self.command = .pickup
            self.droppedItemID.id = droppedItemID
        case .equip(itemID: let itemID):
            self.command = .equip
            self.itemID.id = itemID
        case .unequip(itemID: let itemID):
            self.command = .unequip
            self.itemID.id = itemID
        case .move:
            break
        }
    }
}
