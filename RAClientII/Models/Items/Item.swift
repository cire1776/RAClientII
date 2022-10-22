//
//  Item.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/21/22.
//

import Foundation

public class Item: Hashable, NSCopying, Equatable, Identifiable, Codable {
    public typealias ID = String
    
    public struct Specifier: Hashable, Codable {
        let itemID: Item.ID
        let quantity: UInt
        
        init(_ itemID: Item.ID, _ quantity: UInt) {
            self.itemID = itemID
            self.quantity = quantity
        }
    }
    
    public static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
    
    public var id: ID
    
//    var inventory: SubordinateInventory?
//    var inventoryString: String {
//        guard let inventory = self.inventory else { return "" }
//
//        let arrayOfItems = inventory.items.values.map({ "\($0.quantity) \($0.type.description)" })
//        return arrayOfItems.joined(separator: ", ")
//    }
    
    let typeID: ItemType.ID
    
    var type: ItemType? {
        Game.itemTypes[self.typeID]
    }
    
    var quantity: UInt
    var mass: UInt {
        let ownMass = self.quantity * (self.type?.weight ?? 0) 
        if self.hasInventory {
//            let containedMass = self.inventory!.mass
            return ownMass // + containedMass
        }
        return ownMass
    }
    
    var isEquipped = false
    
    // don't use self.inventory != nil because it screws up initialization.
    var hasInventory: Bool {
//        self.type.hasInventory
        false
    }
    
    init(id: Item.ID?, typeID: ItemType.ID, quantity: UInt) {
        self.id = id ?? UUID().uuidString
        self.typeID = typeID
        self.quantity = quantity
//        self.inventory = nil
        
        let type = Game.itemTypes[typeID]!
        
//        let massCapacity = type.capability?.massCapacity ?? 25
//        let contentFilterID = type.capability?.contentFilterID
        
//        self.inventory =
//                hasInventory ? SubordinateInventory(id: self.id,
//                                massCapacity: massCapacity,
//                                contentFilterID: contentFilterID) : nil
    }
    
    convenience init?(id: ID?, type name: String, quantity: UInt) {
        guard Game.itemTypes.index(forKey: name) != nil else {
            print("Item type not found:", name)
            return nil
        }

        self.init(id: id,  typeID: name, quantity: quantity)
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = Item(id: self.id, type: self.typeID, quantity: self.quantity)
        copy!.isEquipped = self.isEquipped
        return copy!
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension Item {
    func split(quantity: UInt) -> (newStack: Item?, remainder: Item?) {
        
        if self.quantity == quantity {
            return (self, nil)
        }
        
        if quantity == 0 {
            return (nil, self)
        }
        
        self.quantity -= quantity

        return (newStack: Item(id: nil, type: self.type!.id, quantity: 1), remainder: self)
    }
}
