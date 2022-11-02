//
//  SizedFacilityNode.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/1/22.
//

import SpriteKit
import OrderedCollections

/*
 required knowledge: ID, Kind, Size, Interactions, Position, Facing
*/


class SizedFacilityNode: SKSpriteNode, FaceableNode, Updating {
    let facility: Facility
    let kind: Facility.Kind
    let facilitySize: Int
    let interactions = [Facility.Interaction]()
    let venuePosition: VenuePosition
    let facing: Facing
    
    init(for facility: Facility) {
        self.facility = facility
        self.kind = facility.kind
        self.venuePosition = facility.position
        
        self.facilitySize = Int(facility.customProperties["size", default: "0"]) ?? 0
        
        let possibleDiameters = (facility.customProperties["possible diameters"] ?? "16")
            .split(separator: ",")
            .map { Int($0) }
        
        let diameter: Int
        
        if self.facilitySize >= possibleDiameters.count {
            diameter = 16
        } else {
            diameter = possibleDiameters[self.facilitySize] ?? 16
        }
        
        self.facing = facility.facing
        
        let texture = SKTexture(imageNamed: kind.rawValue + "\(facilitySize).png")
        
        super.init(texture: texture, color: .white, size: CGSize(width: diameter, height: diameter))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ currentTime: TimeInterval) {
        self.physicsBody?.angularVelocity = .zero
    }
}


//class TreeNode: SKSpriteNode, Updating {
//    init(facility: Facilities.Tree, holder: EntityHolder) {
//        let treeSize = facility.category.rawValue
//        let diameter = CGFloat((Facilities.Tree.sizes[Facilities.Tree.Category(rawValue: treeSize)! ])!)
//        let texture = SKTexture(imageNamed: "tree\(treeSize).png")
//
//        super.init(texture: texture, color: .white, size: CGSize(width: diameter, height: diameter))
//
//        self.position = holder.convert(position: facility.position)
//        self.zPosition = Constants.facilityLevel
//
//        holder.addChild(self)
//
//        GameScene.updaters.append(update(_:))
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func update(_ currentTime: TimeInterval) {
//        self.physicsBody?.angularVelocity = .zero
//    }
//}