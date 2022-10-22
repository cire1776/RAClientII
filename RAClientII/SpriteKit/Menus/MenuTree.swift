//
//  MenuTree.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/6/22.
//

import SpriteKit
import OrderedCollections

class MenuTree {
    var menus = OrderedSet<MenuNode>()
    let onDismiss: (() -> Void)?
    
    var isDismissedOnExteriorClick = true
    var isDismissedAfterExecution = true
    
    var isActive: Bool {
        !menus.isEmpty
    }
    
    var currentMenu: MenuNode? {
        menus.last
    }
    
    init() {
        self.onDismiss = nil
    }
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
    func openMenu(in parent: SKNode, focusedAt: CGPoint, renderedBy renderer: MenuRenderer) {
        let newMenu = MenuNode(focusedAt: focusedAt, renderedBy: renderer, in: self)
        menus.append(newMenu)
        parent.addChild(newMenu)
        
        newMenu.layout()
    }
    
    func openSubmenu(renderer: MenuRenderer) {
        guard let parentMenu = menus.last else { return }
        
        hideCurrentMenu()
        
        let submenu = MenuNode(focusedAt: parentMenu.focusedAt, renderedBy: renderer, in: self)
        menus.append(submenu)
        parentMenu.parent!.addChild(submenu)
        
        submenu.layout()
    }
    
    func openSubmenu(renderer: @escaping (SKNode, MenuTree)->Void) {
        openSubmenu(renderer: renderer)
    }
    
    private func hideCurrentMenu() {
        currentMenu?.isHidden = true
    }
    
    func dismiss(exteriorClick: Bool) {
        for menu in menus {
            menu.removeFromParent()
        }
        menus.removeAll()
        
        if exteriorClick {
            onDismiss?()
        }
    }
    
    func dismissCurrentMenu(exteriorClick: Bool) {
        guard let currentMenu = menus.last else { return }
        
        currentMenu.removeFromParent()
        menus.removeLast()
        
        if isActive {
            currentMenu.isHidden = false
        }
        
        if exteriorClick {
            onDismiss?()
        }
    }
    
    func contains(_ point: CGPoint) -> Bool {
        guard let currentMenu = menus.last else { return false }
        return currentMenu.contains(point)
    }
}
