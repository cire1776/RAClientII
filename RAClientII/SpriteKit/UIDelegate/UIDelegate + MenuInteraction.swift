//
//  UIDelegate + MenuInteraction.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/2/22.
//

import SpriteKit

extension UIDelegate {
    func handleMenuClick(at position: CGPoint, for menu: MenuTree) {
        let displayedMenu: MenuTree
        
        if self.debugMenu.isActive {
            displayedMenu = self.debugMenu
        } else if self.displayedMenu.isActive {
            displayedMenu = self.displayedMenu
        } else {
            return
        }
        
        guard  displayedMenu.contains(position) else {
            if displayedMenu.isDismissedOnExteriorClick {
                displayedMenu.dismissCurrentMenu(exteriorClick: true)
            }
            return
        }
        
        let currentMenu = displayedMenu.currentMenu
        
        if let background = currentMenu?.childNode(withName: "Background"),
           let container = background.childNode(withName: "Container"),
           let options = container.childNode(withName: "Options") {
                var position = self.scene.convert(position, to: options.parent!)
            
                guard options.contains(position) else { return }
            
                position = options.convert(position, from: options.parent!)

                var executed = false
            
                for option in options.children {
                    
                   if let menuOption = option as? MenuOption,
                      menuOption.contains(position) {
                       menuOption.execute()
                       executed = true
                        break
                    }
                }
               
                if executed && displayedMenu.isDismissedAfterExecution {
                   displayedMenu.dismiss(exteriorClick: false)
                }
                return
            } else {
                print("Problem finding position")
            }
    }
}
