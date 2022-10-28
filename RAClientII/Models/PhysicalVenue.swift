//
//  PhysicalVenue.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/23/22.
//

import Foundation
import UIKit
import GameplayKit

protocol PhysicalVenue : AnyObject, Identifiable {
    var id: String    { get }
    var name: String  { set get }
    var description: String { get }
    
    var region: Hexagon.Region<Geography.TerrainSpecifier> { get set }

    var orientation: Hexagon.Orientation { get set }
    var bounds: CGSize { get set }
    
    var minimap: UIImage? { get set }
    
    var playerCharacter: ActiveCharacter!  { get set }
    var playerCharacterID: Character.ID    { get set }
    
    var charactersPresent: Set<Character.ID> { get set }
    
    var facilities: [Facility.ID : Facility] { get set }
    var facilitiesMap: GKQuadtree<NSObject> { get set }
    
    var droppedItems: [String: DroppedItem] { get set }
    var droppedItemsMap: GKQuadtree<NSObject> { get set }
    
    var interactablesMap: GKQuadtree<NSObject> { get set }
    
    var venue: Venue  { get }
    
    func addFacility(id: Facility.ID?, kind: Facility.Kind, specifier: String, position: VenuePosition) -> Facility?
    
    func add(_ drop: DroppedItem)
    func removeDroppedItem(id: String)
    
//    func add(_ character: Character)
//    func remove(_ characterID: Character.ID)
}

extension PhysicalVenue {
    var venue: Venue {
        let venue = Venue()
        
        venue.region = self.region
        venue.name = self.name
        venue.orientation = self.orientation
        venue.bounds = self.bounds
        venue.minimap = self.minimap
        venue.playerCharacterID = self.playerCharacterID
        venue.charactersPresent = self.charactersPresent
        venue.facilities = self.facilities
        venue.facilitiesMap = self.facilitiesMap
        venue.droppedItems = self.droppedItems
        venue.droppedItemsMap = self.droppedItemsMap
        venue.interactablesMap = self.interactablesMap
        
        return venue
    }
    
    func addFacility(id: Facility.ID? = nil, kind: Facility.Kind, specifier: String, position: VenuePosition) -> Facility? {
//        let id = id ?? UUID().uuidString
//        guard let facility = Facility.factories[kind]?.init(specifier: specifier).build( id: id, at: position) else { return nil }
//
//        self.facilities[facility.id] = facility
//
//        let position = orientation.topology(radius: 100).convert(from:  position)
//
//        self.facilitiesMap.add(facility, at: vector_float2(x: Float(position.x), y: Float(position.y)))
//
//        self.interactablesMap.add(facility, at: vector_float2(x: Float(position.x), y: Float(position.y)))
//
//        return facility
        return nil
    }
    
    func add(_ drop: DroppedItem) {
        droppedItems[drop.id] = drop

        let position = orientation.topology(radius: 100).convert(from: drop.position)

        self.interactablesMap.add(drop, at: vector_float2(x: Float(position.x), y: Float(position.y)))
    }
    
    func removeDroppedItem(id: String) {
        self.droppedItems.removeValue(forKey: id)
    }
}
