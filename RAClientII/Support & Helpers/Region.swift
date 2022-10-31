//
//  Region.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/16/22.
//

import Foundation
import OrderedCollections

extension Hexagon {
    struct Region<T>: Codable where T: Codable {
        static func getOffsets(coordinates: Coordinates, to edge: EdgeType, using topology: Topology) -> (Int, Int) {
            return topology.normalOffsets[edge]!
        }
        
        struct AxialCoordinate: Hashable, Codable {
            let r: Int, q: Int
        }
        
        var hexes: OrderedDictionary<AxialCoordinate, T?>
        let width: Int
        let height: Int

        var first: (Coordinates, T)? {
            var element: T? = nil
            
            for (key, possibleHex) in hexes {
                guard let possibleHex = possibleHex  else { continue }
                element = possibleHex
                return ((x: key.r, y: key.q), element!)
            }
            return nil
        }
       
        init() {
            self.hexes = [:]
            self.width = 0
            self.height = 0
        }
        
        init(hexes: [T?], orientation: Hexagon.Orientation, width: Int) {
            self.hexes = [:]
            self.width = width
            self.height = Int(ceil(Double(hexes.count) / Double(width)))
            
            var x = 0, y = 0
            
            for element in hexes {
                defer {
                    x += 1
                    if x >= width {
                        x = 0
                        y += 1
                    }
                }
                
                guard let element = element else { continue }
                
                self.hexes[AxialCoordinate(r: x, q: y)] = element
            }
        }
        
        public var isWholeMap: Bool = false
        
        func ForEach(perform action: (T,(Int,Int))->()) {
            for (key, hex) in hexes {
                if let hex = hex {
                    action(hex, (key.r,key.q))
                }
            }
        }
        
        func getHex(at coordinates:  Coordinates, dx: Int=0, dy: Int=0) -> (Coordinates,T)? {
            let r = coordinates.x + dx
            let q = coordinates.y + dy
            
            let index = AxialCoordinate(r: r, q: q)
            
            if let element = self.hexes[index] {
                // why do I need to unwrap element that is unwrapped above?
                
                return ((x: r, y: q), element!)
            } else {
                return nil
            }
        }
        
        func containsHex(at coordinates: Coordinates) -> Bool {
             getHex(at: coordinates) != nil
        }
        
        func getEmptyEdge(coordinates: Coordinates, using topology: Topology) -> EdgeType? {
            let coordinates = coordinates
            
            var edge: EdgeType = topology.startingEdge
            
            repeat {
                let offsets = Hexagon.Region<T>.getOffsets(coordinates: coordinates, to: edge, using: topology)
                let hex = getHex(
                    at: coordinates,
                    dx: offsets.0,
                    dy: offsets.1)
                if let _ = hex {
                    edge = topology.successor[edge]!
                } else {
                    return edge
                }
            } while (edge != .rightTop)
            
            return nil
        }
       
        func getAdjoiningHex(of edge: EdgeType, at coordinates: Coordinates, using topology: Topology) -> (Coordinates, T)? {
            let (dx, dy) = Hexagon.Region<T>.getOffsets(coordinates: coordinates, to: edge, using: topology)

            if let (coordinates, element) = getHex(at: coordinates, dx: dx, dy: dy) {
               return (coordinates, element)
            } else {
                return nil
            }
        }
        
        func collectEdges(using topology: Topology) -> OrderedSet<Hexagon.Edge> {
            guard var (coordinates, _) = self.first else { abort() }

            guard let startingEdge = self.getEmptyEdge(coordinates: coordinates, using: topology) else {
                print("No empty edges found:  \(coordinates)")
                return []
            }
            
            var edge = startingEdge
            let startingPosition = coordinates
            
            var edges = OrderedSet<Hexagon.Edge>()
            
            repeat {
                (coordinates, edge) = walkEdge(coordinates: coordinates, edge: edge, using: topology, edges: &edges)
            } while (edge != startingEdge || coordinates != startingPosition)
            
            return edges
        }
        
        private func walkEdge(coordinates: Coordinates, edge: Hexagon.EdgeType, using topology: Topology, edges: inout OrderedSet<Edge>) -> (Coordinates, EdgeType) {
            var coordinates = coordinates
            var edge = edge
            
            let (adjoiningHex, _) = self.getAdjoiningHex(of: edge, at: coordinates, using: topology) ?? (nil, nil)
            
            if let adjoiningHex = adjoiningHex {
                coordinates = adjoiningHex
                edge = Hexagon.EdgeComplements[edge]!
            } else {
                edges.append(Hexagon.Edge(edgeType: edge, column: coordinates.0, row: coordinates.1))
            }
            edge = topology.successor[edge]!
            
            return (coordinates, edge)
        }
        
        func randomHex() -> Coordinates {
            let index = Int.random(in: 0..<hexes.count)
            let hex = hexes.elements[index]
            return (hex.key.q, hex.key.r)
        }
    }
}
