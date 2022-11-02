//
//  TreeMenuRenderer.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/6/22.
//

import SpriteKit

struct FacilityMenuRenderer: MenuRenderer {
    let facility: Facility
    
    init(for facility: Facility) {
        self.facility = facility
    }
    
    func render(to container: Container, menuTree: MenuTree) {
        container.title = "Facility".capitalized
        
        for interaction in facility.interactions {
            let gameScene = container.scene as! GameScene
                        
            let label = String(interaction
                        .split(separator: ":")
                        .first!)
                        .capitalized
                        
            
            container.accept(menuOption: SimpleMenuOption(text: label) {
                print("interaction:",interaction)
            })
        }
    }
}

