//
//  MarkerAdornable.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/29/22.
//

import SpriteKit

protocol MarkerUser {
    func markerColor(isCurrent: Bool) -> SKColor
}

extension MarkerUser {
    func markerColor(isCurrent: Bool) -> SKColor {
        isCurrent ? .blue : .yellow
    }
    
    
}

protocol MarkerAdornable: SKNode {
    var markerLayer: SKNode { get }
    
    func markerName(for position: VenuePosition, as annotation: String?) -> String

    func displayMarker(named name: String, at position: CGPoint, styler: (CGPoint)->SKNode)

    func lookupMarker(at position: VenuePosition, as annotation: String?) -> SKNode?
    
    func clearMarker(named name: String)
    
    func clearAllMarkers()
}

extension MarkerAdornable {
    func markerName(for position: VenuePosition, as annotation: String? = nil) -> String {
        let annotation = annotation == nil ? "" : annotation! + " "
        return "\(annotation)\(position.hex.0) \(position.hex.1) \(Int(position.x)) \(Int(position.y))"
    }
    
    func displayMarker(named name: String, at position: CGPoint, styler: (CGPoint)->SKNode) {
        
        let node = styler(position)
        node.name = name
        node.position = CGPoint(x: position.x, y: position.y)
        node.zPosition = Constants.adornerLevel
        
        markerLayer.addChild(node)
    }
    
    var markerLayer: SKNode {
        var layer = self.childNode(withName: Constants.markerLayerName)
        
        if layer == nil {
            layer = SKNode()
            layer!.name = Constants.markerLayerName
            self.addChild(layer!)
        }
        
        return layer!
    }
    
    func lookupMarker(at position: VenuePosition, as annotation: String?) -> SKNode? {
        markerLayer.childNode(withName: markerName(for: position, as: annotation))
    }
    
    func clearMarker(named name: String) {
        while true {
            if let markerNode = markerLayer.childNode(withName: name) {
                markerNode.removeFromParent()
            } else {
                break
            }
        }
    }
    
    func clearAllMarkers() {
        markerLayer.removeFromParent()
    }
}
