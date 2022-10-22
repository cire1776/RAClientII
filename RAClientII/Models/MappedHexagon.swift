//
//  MappedHexagon.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/22/22.
//

import CoreGraphics

struct MappedHexagon: Hashable, Codable {
    static func == (lhs: MappedHexagon, rhs: MappedHexagon) -> Bool {
        lhs.hexagon == rhs.hexagon &&
        lhs.coordinates.0 == rhs.coordinates.0 &&
        lhs.coordinates.1 == rhs.coordinates.1
    }

    let hexagon: Hexagon
    let coordinates: (Int, Int)
    let radius: CGFloat
    
    init(_ hexagon: Hexagon, at coordinates: (Int, Int), of radius: CGFloat) {
        self.hexagon = hexagon
        self.coordinates = coordinates
        self.radius = radius
    }
    
    enum CodingKeys: CodingKey {
        case hexagon
        case coordinatesX, coordinatesY
        case radius
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<MappedHexagon.CodingKeys> = try decoder.container(keyedBy: MappedHexagon.CodingKeys.self)
        
        self.hexagon = try container.decode(Hexagon.self, forKey: MappedHexagon.CodingKeys.hexagon)
        
        self.coordinates.0 = try container.decode(Int.self, forKey: MappedHexagon.CodingKeys.coordinatesX)
        
        self.coordinates.1 = try container.decode(Int.self, forKey: MappedHexagon.CodingKeys.coordinatesY)

        self.radius = try container.decode(CGFloat.self, forKey: MappedHexagon.CodingKeys.radius)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MappedHexagon.CodingKeys.self)
        
        try container.encode(self.hexagon, forKey: MappedHexagon.CodingKeys.hexagon)
        
        try container.encode(self.coordinates.0, forKey: MappedHexagon.CodingKeys.coordinatesX)

        try container.encode(self.coordinates.1, forKey: MappedHexagon.CodingKeys.coordinatesY)

        try container.encode(self.radius, forKey: MappedHexagon.CodingKeys.radius)
    }

    var topology: Topology {
        hexagon.orientation.topology(radius: radius)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(coordinates.0)
        hasher.combine(coordinates.1)
    }
}
