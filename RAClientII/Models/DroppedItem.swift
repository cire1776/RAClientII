//
//  DroppedItem.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/19/22.
//

import Foundation
import CoreGraphics
import SpriteKit

protocol Interactable: NSObject {
    var position: VenuePosition { get set }
    var type: InteractableType { get }
}

public enum InteractableType: Codable {
    case droppedItem, character, player, facility
    case other
}

class DroppedItem: NSObject, NSCopying, Codable, Identifiable, Interactable {
    static func == (lhs: DroppedItem, rhs: DroppedItem) -> Bool {
        lhs.position == rhs.position
    }
    
    let id: String
    
    var type: InteractableType = .droppedItem
    
    var item: Item
    var position: VenuePosition
    
    init(_ item: Item, at position: VenuePosition) {
        self.id = item.id
        self.item = item
        self.position = position
    }
    
    init(_ item: Item, at position: VenuePosition, within range: CGFloat) {
        self.id = item.id
        self.item = item
        
        let newX = position.x + Int(CGFloat.random(in: -range / 2..<range / 2))
        let newY = position.y + Int(CGFloat.random(in: -range / 2..<range / 2))
        
        self.position = VenuePosition(hex:position.hex, x: newX, y: newY)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        DroppedItem(self.item, at: self.position)
    }
}
