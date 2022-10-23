//
//  Protobuff.swift
//  RAClientII
//
//  Created by Eric Russell on 10/22/22.
//

import Foundation
import SwiftProtobuf

extension RABackend_GameCommand {
    init(clientCommand: ClientCommand) {
        switch clientCommand {
        case .connect:
            self.command = .connect
        case .report:
            self.command = .report
        case .close:
            self.command = .close
        case .beginOperation:
            self.command = .beginOperation
        case .cancelOperation:
            self.command = .cancelOperation
        case .command:
            self.command = .command
        case .face(let facing):
            self.command = .face
            self.facing = UInt64(facing)
        case .addWaypoint:
            self.command = .addWaypoint
        case .abortMovement:
            self.command = .abortMovement
        case .abortLastWaypoint:
            self.command = .abortLastWaypoint
        case .consume:
            self.command = .consume
        case .use:
            self.command = .use
        case .drop:
            self.command = .drop
        case .pickup:
            self.command = .pickup
        case .equip:
            self.command = .equip
        case .unequip:
            self.command = .unequip
        default:
            self.command = .nop
        }
    }
}

extension RABackend_Orientation {
    var toOrientation: Hexagon.Orientation {
        self == .point ? .point : .flat
    }
}

extension RABackend_Size {
    var toCGSize: CGSize {
        CGSize(width: self.width, height: self.height)
    }
}
