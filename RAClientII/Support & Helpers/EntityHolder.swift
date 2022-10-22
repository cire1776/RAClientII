//
//  EntityHolder.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/20/22.
//

import SpriteKit

protocol Converter {
    func convert(position: VenuePosition) -> CGPoint
}

protocol EntityHolder: Converter {
    func addChild(_ child: SKNode)
}

class HolderNode: SKNode, EntityHolder {
    func convert(position: VenuePosition) -> CGPoint {
        (self.parent as? EntityHolder)?.convert(position: position) ?? .zero
    }
}
