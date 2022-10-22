//
//  HexagonMap.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/24/22.
//

import CoreGraphics

/*
    /\/\
    ||||
    \/\/
*/
extension Hexagon {
    struct Map<T> where T: Codable {
        let region: Hexagon.Region<T>
        let diameter: Int
        let orientation: Hexagon.Orientation
        
        func contains(point: CGPoint) -> Bool {
            false
        }
    }
}
