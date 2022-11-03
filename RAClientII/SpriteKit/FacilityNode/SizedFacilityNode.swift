//
//  SizedFacilityNode.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/1/22.
//

import SpriteKit
import OrderedCollections

class SizedFacilityNode: SKSpriteNode, FaceableNode, Updating {
    let facility: Facility
    let kind: Facility.Kind
    let category: Int
    let interactions = [Facility.Interaction]()
    let venuePosition: VenuePosition
    let facing: Facing
    
    init(for facility: Facility, in holder: EntityHolder) {
        self.facility = facility
        self.kind = facility.kind
        self.venuePosition = facility.position
        
        self.category = Int(facility.customProperties["category", default: "0"]) ?? 0
        
        let possibleDiameters = (facility.customProperties["sizes"] ?? "4")
            .split(separator: ",")
            .map { Int($0) }
        
        let diameter: Int
        
        if self.category > possibleDiameters.count {
            diameter = 4
        } else {
            diameter = possibleDiameters[self.category] ?? 4
        }
        
        self.facing = facility.facing
        
        let texture = SKTexture(imageNamed: kind.rawValue + "\(category).png")
        
        super.init(texture: texture, color: .white, size: CGSize(width: diameter, height: diameter))
 
        self.position = holder.convert(position: self.venuePosition)
        
        holder.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ currentTime: TimeInterval) {
        self.physicsBody?.angularVelocity = .zero
    }
}


