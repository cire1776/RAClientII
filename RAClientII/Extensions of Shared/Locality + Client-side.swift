//
//  Local + Client-side.swift
//  RAClientII
//
//  Created by Eric Russell on 10/21/22.
//

import Foundation
import OrderedCollections

extension Locality {
    mutating func updateFromAuthoritative(_ authoritative: Locality) {
        var authoritative = authoritative
        
        // search forward in authoritative to find obsolete waypoints in .predictive
        for var waypoint in self.waypoints {
            if authoritative.waypoints.firstIndex(of: waypoint) == nil {
                waypoint.deleted = true
            } else {
                break
            }
        }
            
        // search backwards in .predictive to find new waypoints
        for waypoint in self.waypoints.reversed() {
            if authoritative.waypoints.firstIndex(of: waypoint) == nil {
                authoritative.waypoints.append(waypoint)
            } else {
                break
            }
        }
        self = authoritative
        self.type = .predictive
        self.waypoints = OrderedSet(self.waypoints.filter { !$0.deleted })
    }
}
