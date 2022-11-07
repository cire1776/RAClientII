//
//  FaceableCommand.swift
//  RAClientII
//
//  Created by Eric Russell on 11/1/22.
//

import Foundation

extension Command {
    static public func Face(facing: UInt) {
        Task {
            let command:(ClientCommand, ClientCommand?) = (.face(facing: facing), nil)
            await queue.push(command)
        }
    }
}
