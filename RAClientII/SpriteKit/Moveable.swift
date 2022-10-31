//
//  Moveable.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/29/22.
//

import SpriteKit

protocol Moveable {
    var locality: Locality { get set }
    
    func markerColor(isCurrent: Bool) -> SKColor
    
    func movementStarted(at currentTick: UInt64)
    func addWaypoint(to destination: CGPoint)
    
    func moveAuthoritatively(_ locality: Locality)
}
