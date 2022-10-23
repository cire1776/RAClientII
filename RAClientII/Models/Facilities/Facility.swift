//
//  Facility.swift
//  CommonLibrary
//
//  Created by Eric Russell on 9/26/22.
//

import Foundation

public struct FacilityList: NoncodableDataList {
    
    public typealias T = Facility
    
    public var items = [T.ID : T]()
    
    public init() {}
    
    public init(dictionary: [String : T]) {
        self.items = dictionary
    }
}

public extension Constants {
    static let facilityOperatingRange = CGFloat(20)
}

public enum Facilities {}

public class Facility: NSObject, Identifiable, Interactable {
    public typealias ID = String
    public enum Kind: String, Codable, Equatable, Hashable {
        case tree, fruitTree
        case sawMill
        case rubblePile
    }
    
    public var id: Facility.ID
    
    public var type: InteractableType = .facility
    public var kind: Kind
    
    public var position: VenuePosition
    
    public var buffs = [BuffSpecifier.ID : BuffSpecifier]()
    
//    public var totalSkillBuffs = [Skill : Int]()
    
    public var customProperties = [String : String]()
        
    public init(kind: Kind) {
        self.id = UUID().uuidString
        self.type = .facility
        self.kind = kind
        self.position = .zero
        
        super.init()
    }
    
    public init(id: Facility.ID, at position: VenuePosition) {
        self.id = id
        self.position = position
        self.kind = .tree
        self.type = .facility
        
        super.init()
    }
    
    public func isEqualTo(other: Facility) -> Bool {
        self.id == other.id &&
        self.position == other.position &&
        self.kind == other.kind &&
        self.type == other.type
    }
    
    public func update(_ endorsement: Endorsement.Key, xp: UInt) {
    }
    
    public func hasAdded(key: Endorsement.Key, endorsement: Endorsement) {
    }
    
    public func hasRemoved(endorsement: Endorsement.Key) {
    }
    
    public func initialBuffs(actionNotifier: ActionRegisterable) throws {
    }
    
    public func hasAdded(buff: BuffSpecifier) {
    }
    
    public func hasRemoved(buff: BuffSpecifier) {
    }
    
    public func canOperate(character: Character) -> Bool {
        let converter = Hexagon.Orientation.point.topology(radius: 100).convert(from:)
        let distance = character.locality.position.distance(to: self.position, converter: converter)
        return  distance <= Constants.facilityOperatingRange
    }
}
