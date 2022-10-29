//
//  FaceableNode.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/28/22.
//

import SpriteKit


protocol FaceableNode: SKNode  {
    func setFacing(_ venuePosition: VenuePosition)
    
    func setFacing(to facing: Facing, for orientation: Hexagon.Orientation)
    
    func setFacing(toRadians rotation: Double, for orientation: Hexagon.Orientation)
    
    func setFacing(towards destination: CGPoint)
    
    func setFacing(towardsHex hex: Coordinates)
    
    func setFacing(toExactly rotation: Double, for orientation: Hexagon.Orientation)
}

extension FaceableNode {
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
    
    func setFacing(_ venuePosition: VenuePosition) {
        let gameScene = self.scene as! GameScene
        let hexagonNodeMap = gameScene.hexagonMapNode
        
        let destination = hexagonNodeMap!.convert(position: venuePosition)
        
        setFacing(towards: destination)
    }
    
    // facing can be 0 to 5
    func setFacing(to facing: Facing, for orientation: Hexagon.Orientation) {
        let rotation = Self.facingAngles[Int(facing)]
        print("facing:", facing, "rotation",Double(rotation).radiansToDegrees)
        setFacing(toExactly: rotation, for: orientation)
    }
    
    func setFacing(toRadians rotation: Double, for orientation: Hexagon.Orientation) {
        let distances = Self.facingAngles.enumerated().map {(abs($1 - rotation).truncatingRemainder(dividingBy: 2 * .pi),$0)}
        let (_, index) = distances.min { $0.0 < $1.0 }!
        setFacing(to: Facing(index), for: orientation)
    }
    
    func setFacing(towards destination: CGPoint) {
        let difference = destination - self.position
        let direction = CGVector(dx: difference.x, dy: difference.y)
        let angleOfTravel = direction.angle()
        setFacing(toExactly: -angleOfTravel, for: .flat)
    }
    
    func setFacing(towardsHex hex: Coordinates) {
        let parent = self.parent!
        
        let hexNode = parent.childNode(withName: Hexagon.nameFrom(coordinates: (x: hex.0, y: hex.1)))
        
        let destination = hexNode!.convert(.zero, to: parent)

        self.setFacing(towards: destination)
    }
    
    func setFacing(toExactly rotation: Double, for orientation: Hexagon.Orientation) {
        var rotation = rotation
        
        if orientation == .point {
            rotation += 30.degreesToRadians
        }
        
        rotation = rotation.truncatingRemainder(dividingBy: 2 * .pi)
        
        let action = SKAction.rotate(toAngle: rotation, duration: 0.3)
        self.run(action)
    }
}
