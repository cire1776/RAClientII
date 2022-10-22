//
//  MenuRenderer.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/6/22.
//

import SpriteKit

protocol MenuRenderer {
    func render(to: Container, menuTree: MenuTree)
}

struct InlineRenderer : MenuRenderer {
    let renderer: (Container, MenuTree) -> Void
    init(renderer: @escaping (SKNode, MenuTree)->Void) {
        self.renderer = renderer
    }
    
    func render(to parent: Container, menuTree: MenuTree) {
        renderer(parent, menuTree)
    }
}

