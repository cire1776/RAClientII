//
//  ItemHolding.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/13/22.
//

import Foundation

protocol ItemHolding: AnyObject, Identifiable where ID == String {
    var items: [String : Item]  { get set }
    
    func initialInventory()
    func resetInventory()
    
    func canAccept(_ item: Item) -> Bool
    
    func add(item: Item, authority: ActionReliability)
    func add(items: Set<Item>, authority: ActionReliability)
    func addStacked(item: Item) -> Set<Item>
    
    func reduce(itemID: String, quantity: UInt) -> Set<Item>
    
    func reduce(itemType: ItemType.ID, quantity: UInt)
    
    func remove(itemID: String)
    
    func getStacks(of itemType: ItemType) -> Set<Item>
    func getOrderedStacks(of itemTypeID: ItemType.ID) -> [Item]
    
    func has(itemOfType type: String, quantity: UInt) -> Bool 
}

protocol MainItemHolding : ItemHolding {
//    var subordinate: SubordinateInventory? { get }
    var isUsingSubordinate: Bool { get }
}

extension ItemHolding {
    func initialInventory() {}
}

extension MainItemHolding where Self:Character {
    func initialInventory() {
        self.add(item: Item(id: nil, type: "log, pine", quantity: 10)!, authority: .authoritative)
        
        self.add(item: Item(id: nil, type: "apple", quantity: 10)!, authority: .authoritative)
        
        self.add(item: Item(id: nil, type: "tree, pine, whip", quantity: 1)!, authority: .authoritative)
        
        self.add(item: Item(id: nil, type: "tree, pine, seedling", quantity: 10)!, authority: .authoritative)
        
        self.add(item: Item(id: nil, type: "hatchet", quantity: 1)!, authority: .authoritative)
        
        self.add(item: Item(id: nil, type: "axe", quantity: 1)!, authority: .authoritative)

        self.add(item: Item(id: nil, type: "shovel", quantity: 1)!, authority: .authoritative)
        
        self.add(item: Item(id: nil, type: "basket, small", quantity: 1)!, authority: .authoritative)
        
        self.add(item: Item(id: nil, type: "necklace of forestry", quantity: 1)!, authority: .authoritative)
        
        self.add(item: Item(id: nil, type: "necklace of farming", quantity: 1)!, authority: .authoritative)
        
        self.add(item: Item(id: nil, type: "necklace of construction", quantity: 1)!, authority: .authoritative)
    }
}

extension MainItemHolding {
    var totalWeight: Double {
        items.values.reduce(0) { accum, item in
            accum + Double(item.type!.weight * item.quantity) / 100.0
        }
    }
    
    func initialInventory() {}
    
    func resetInventory() {
        self.items = [:]
    }
    
    func getStacks(of itemType: ItemType) -> Set<Item> {
        var results = Set<Item>()
        
        for (_, item) in self.items {
            if item.type == itemType {
                results.insert(item)
            }
        }
        
        return results
    }
    
    func getOrderedStacks(of itemTypeID: ItemType.ID) -> [Item] {
        var results = [Item]()
        
        for (_, item) in self.items {
            if item.type?.id == itemTypeID {
                results.append(item)
            }
        }
        
        results.sort(by: { $0.quantity < $1.quantity })
        
        return results
    }
    
    // Transfer seems to always be authoritative
    func transfer(item: Item, source: any ItemHolding) {
        fatalError("Not Yet Implmemented")
    }
    
    // add treats the item as if it is de novo
    func add(item: Item, authority: ActionReliability) {
        let id = item.id
        
//        if self.isUsingSubordinate,
//           self.subordinate!.canAccept(item)
//        {
//            guard authority == .authoritative else { return }
//
//            let subordinateInventory = self.subordinate
//            subordinateInventory?.add(item: item, authority: .authoritative)
//
//            var newBalance = Set<Item>()
//            for item in (subordinateInventory?.items.values)! {
//                newBalance.insert(item)
//            }
//
//            Game.game.server.updateSubordinateInventory(newBalance: newBalance)
//        } else {
            Task {
                await MainActor.run {
                    if item.quantity == 0 {
                        self.remove(itemID: id)
                    } else {
                        self.items[id] = item
//                        fatalError()
                    }
                }
//                
//                if authority == .predictive {
//                    GameClient.server.add(item: item)
//                }
        }
    }
    
    func add(items: Set<Item>, authority: ActionReliability) {
        for item in items {
            self.add(item: item, authority: authority)
        }
    }
    
    func addStacked(item: Item) -> Set<Item> {
        var results = Set<Item>()
        
        let itemType = item.type
        if itemType!.isStackable {
            let item = item
            let stackSize = itemType?.stackSize
            
            let stacks = getStacks(of: itemType!)
            
            for stack in stacks {
                if stack.quantity < stackSize! {
                    let addedItems = min(item.quantity, stackSize! - stack.quantity)
                    stack.quantity += addedItems
                    item.quantity -= addedItems
                    if addedItems > 0 {
                        results.insert(stack)
                    }
                }
            }
            
            while item.quantity > stackSize! {
                let newItem = Item(id: nil, type: itemType!.id, quantity: stackSize!)!
                results.insert(newItem)
                item.quantity -= stackSize!
            }
        
            if item.quantity > 0 {
                results.insert(item)
            }
            
            self.add(items: results, authority: .authoritative
            )
        } else {
            let item = item
            for _ in 0..<item.quantity - 1 {
                let newItem = Item(id: nil, type: itemType!.id, quantity: 1)!
                self.add(item: newItem, authority: .authoritative)
                results.insert(newItem)
            }
            
            item.quantity = 1
            self.add(item: item, authority: .authoritative)
            results.insert(item)
        }
        
        return results
    }
    
    func reduce(itemID: String, quantity: UInt) -> Set<Item> {
        guard let item = self.items[itemID] else { return []}

        var quantityRemaining = quantity
        
        var numberConsumed = min(item.quantity, quantityRemaining)

        var changedItems = Set<Item>()
        
        item.quantity -= numberConsumed
        quantityRemaining -= numberConsumed
        
        if numberConsumed > 0 {
            changedItems.insert(item)
        }
        
        if item.quantity == 0 {
            remove(itemID: item.id)
        }
        
        for stack in getStacks(of: item.type!) {
            numberConsumed = min(stack.quantity, quantityRemaining)
            stack.quantity -= numberConsumed
            quantityRemaining -= numberConsumed
            
            if stack.quantity == 0 {
                remove(itemID: stack.id)
            }
            
            if numberConsumed > 0 {
                changedItems.insert(item)
            }
            
            if quantityRemaining == 0 { break }
        }
        
        return changedItems
    }
    
    func reduce(itemType: ItemType.ID, quantity: UInt)  {
        guard has(itemOfType: itemType, quantity: quantity) else { return }
        
        let stacks = getOrderedStacks(of: itemType)
        let changedStacks: Set<Item>
        
        if let smallestStack = stacks.last {
            changedStacks = reduce(itemID: smallestStack.id, quantity: quantity)
        } else {
            changedStacks = []
        }
        
//        for stack in changedStacks {
//            GameClient.server.consume(itemID: stack.id)
//        }
    }
    
    func remove(itemID: String) {
        Task {
            await MainActor.run {
                items.removeValue(forKey: itemID)
            }
        }
    }
    
    func has(itemOfType type: String, quantity: UInt) -> Bool {
//        guard let itemType = Game.itemTypes[type] else { return false }
//        let count = getStacks(of: itemType).reduce(0) { accum, current in
//            accum + current.quantity
//        }
//
//        return count >= quantity
        false
    }
}
