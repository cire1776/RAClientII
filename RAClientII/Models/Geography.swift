//
//  Geography.swift
//  Royal Ambition
//
//  Created by Eric Russell on 1/30/22.
//

import CoreGraphics

public typealias Coordinates = (x: Int, y: Int)

public struct Geography {
    public typealias HexSpecifier = (y: Int, x: Int)

    public typealias SelectionSpecifier = (y: Int, x: Int, ref: String)
    
    public typealias AdjustColumnFunction = (_ row: Int, _ adjustedColumn: inout Int)->()
    
    public struct TerrainSpecifier: Codable {
        enum CodingKeys: CodingKey {
            case terrain, modifier
        }
        
        public var terrain: Terrain?
        public var modifier: Terrain.Modifier
        
        public var components: (terrain: Terrain?, modifier: Terrain.Modifier) {
            (terrain: terrain, modifier: modifier)
        }
        
        public var isNone: Bool {
            terrain == Terrain.none
        }
        
        public var isSea: Bool {
            terrain == .ocean || terrain == .coastal
        }
        
        public init() {
            terrain = Terrain.none
            modifier = .plain
        }
        
        public init(terrain: Terrain?, modifier: Terrain.Modifier) {
            self.terrain = terrain
            self.modifier = modifier
        }
        
        public init(_ terrain: Terrain?, _ modifier: Terrain.Modifier) {
            self.terrain = terrain
            self.modifier = modifier
        }
    }
}

protocol GeographicRenderer {
    func drawTerrainLayer(using entity: GeographicEntity)
    func erase(using entity: GeographicEntity)
    func erase()
}

protocol GeographicEntity {
    var origin: CGPoint { get }
    var z: Int          { get }
    var bounds: CGRect   { get }
    var extent: CGSize  { get }
    var xAdjustment: Int { get }
    var createdOnEvenRow: Bool { get }
    
    var adjustColumn: Geography.AdjustColumnFunction? { get }
    
    func isEquivalent(to other: GeographicEntity) -> Bool
    
    func ghost() -> GeographicEntity?
    func ghost(renderer: GeographicRenderer?) -> GeographicEntity?
    
    func erase()
}

extension GeographicEntity {
    var bounds: CGRect {
        CGRect(origin: origin, size: extent)
    }
    
    func isEquivalent(to other: GeographicEntity) -> Bool {
        return bounds == other.bounds && z == other.z
    }
    
    func erase() {
//        RoyalAmbitionGame.shared.erasedEntities.append(self)
    }
}

struct GeographicState: GeographicEntity  {
    let origin: CGPoint
    let z: Int
    let extent: CGSize
    
    var xAdjustment: Int
    let createdOnEvenRow: Bool
    let adjustColumn: Geography.AdjustColumnFunction?

    let renderer: GeographicRenderer?
    
    init(_ entity: GeographicEntity, renderer: GeographicRenderer?) {
        self.origin = entity.origin
        self.z = entity.z
        self.extent = entity.extent
        
        var xAdjustment = 0
        entity.adjustColumn?(Int(origin.x)+1, &xAdjustment)
        self.xAdjustment = xAdjustment
        
        self.createdOnEvenRow = entity.createdOnEvenRow

        self.adjustColumn = entity.adjustColumn
        
        self.renderer = renderer
    }
    
    func ghost() -> GeographicEntity? { return nil}
    
    func ghost(renderer: GeographicRenderer?) -> GeographicEntity? { return nil }
}

