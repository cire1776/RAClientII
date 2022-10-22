//
//  Hexagon + NameFrom.swift
//  RAClientII
//
//  Created by Eric Russell on 10/20/22.
//

import Foundation

public extension Hexagon {
    static func nameFrom(coordinates: Coordinates) -> String{
        "\(coordinates.0),\(coordinates.1)"
    }
}
