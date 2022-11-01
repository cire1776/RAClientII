//
//  UIDelegate + Zoom.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/30/22.
//

import SpriteKit

extension UIDelegate {
    func setupZoom(_ view: SKView) {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(Self.pinch(sender:)))
        view.addGestureRecognizer(pinch)
    }
    
    @objc
    private func pinch(sender:UIPinchGestureRecognizer) {
        let node = scene.camera
        
        if let node = node {
            switch (sender.state) {
            case .began:
                originalScaleFactor = node.xScale
            case .changed:
                let scaleFactor = sender.scale / originalScaleFactor
                node.setScale(1/scaleFactor)
            default:
                break
            }
        } else {
            print("Node not found")
        }
    }
}
