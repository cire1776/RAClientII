//  Faceable.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/28/22.
//

import SpriteKit
import CoreGraphics

public typealias Facing = UInt

protocol Faceable: AnyObject  {
    var facing: Facing  { get set }
    
    var locality: Locality { get set }
    
    func setFacing(to facing: Facing)
    
    func setFacing(towards: CGPoint, for orientation: Hexagon.Orientation)
    
    func setFacing(toRadians rotation: Double, for orientation: Hexagon.Orientation)
}

extension Faceable {
    static var facingAngles : [CGFloat] {
        [
        0,
        60.degreesToRadians,
        120.degreesToRadians,
        180.degreesToRadians,
        240.degreesToRadians,
        300.degreesToRadians,
        ]
    }
    
    func setFacing(to facing: Facing) {
        print("setting facings to", facing)
        self.facing = facing
    }
    
    func setFacing(toRadians rotation: Double, for orientation: Hexagon.Orientation) {
        let distances = Self.facingAngles.enumerated().map {(abs($1 - rotation).truncatingRemainder(dividingBy: 2 * .pi),$0)}
        let (_, index) = distances.min { $0.0 < $1.0 }!
        setFacing(to: Facing(index))
    }
    
    func setFacing(towards destination: CGPoint, for orientation: Hexagon.Orientation) {
        let position = orientation.topology(radius: 100).convert(from: self.locality.position)
        let difference = destination - position
        let direction = CGVector(dx: difference.x, dy: difference.y)
        let angleOfTravel = -direction.angle()
        print(angleOfTravel)
        setFacing(toRadians: angleOfTravel, for: .point)
    }
}
