//
//  Updating.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/29/22.
//

import Foundation

typealias Updater = (_ currentTime: TimeInterval)->Void

protocol Updating {
    func update(_ currentTime: TimeInterval)
}
