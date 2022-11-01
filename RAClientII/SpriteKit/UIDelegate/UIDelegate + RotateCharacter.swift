//
//  UIDelegate + RotateCharacter.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/30/22.
//

import SpriteKit

extension UIDelegate {
    func setupRotateCharacter(_ view: SKView) {
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(Self.rotate(sender:)))
        view.addGestureRecognizer(rotate)
    }
    
    @objc
    private func rotate(sender: UIRotationGestureRecognizer) {
        guard let node = scene.hexagonMapNode.children.first(where: { child in
            child.name?.starts(with: "character:player:") ?? false
        } ) as? CharacterNode
        else { return }
            
        switch sender.state {
        case .began:
            lastRotation = 0
            startingRotation = node.zRotation
        case .changed:
            let delta = sender.rotation - lastRotation
            node.zRotation -= delta
            lastRotation = sender.rotation
        case .ended:
            node.setFacing(toRadians: lastRotation, for: scene.orientation)
            Command.Face(facing: UInt(Int(lastRotation / (.pi/3)) + 3))
        case .cancelled:
            node.zRotation = startingRotation
        default:
            break
        }
    }
}
