//
//  DroppedItemPickupRenderer.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/19/22.
//

import Foundation


struct DroppedItemPickupRenderer: MenuRenderer {
    let droppedItem: DroppedItem
    
    func render(to container: Container, menuTree: MenuTree) {
        container.title = "\(droppedItem.item.quantity) \(droppedItem.item.type!.description)"
        container.accept(menuOption: SimpleMenuOption(text: "Pick Up") {
//            Command.Pickup(droppedItem: droppedItem)
        })
    }
}
