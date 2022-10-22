//
//  Terrain.swift
//  Royal Ambition
//
//  Created by Eric Russell on 1/28/22.
//

import Foundation

public enum Terrain: Hashable,Codable {
    public enum Modifier: Hashable, Codable {
        case plain
        case wooded(Int)
        case rocky(Int)
        case lake, pond, wetland
        case volcanic
        
        static func codeToModifier(code: String) -> Modifier {
            switch code {
            case "1","2","3","4","5":
                return .wooded(Int(code)!)
            case "6","7", "8":
                return .rocky(Int(code)!-5)
            default:
                return .plain
            }
        }
        
        static func modifierToCode(_ modifier: Modifier) -> String {
            switch modifier {
            case wooded(let degree):
                return degree.description
            case .rocky(let degree):
                return degree.description
            default:
                return " "
            }
        }
        
        static var nameToModifier:[String:Modifier] = [
            "rocky1" : .rocky(1),
            "rocky2" : .rocky(2),
            "rocky3" : .rocky(3),
            "wooded1" : .wooded(1),
            "wooded2" : .wooded(2),
            "wooded3" : .wooded(3),
            "wooded4" : .wooded(4),
            "wooded5" : .wooded(5),
        ]
        
        static var nameFromTerrain:[Terrain:String] = [:]
    }
    
    static var translationToTerrain:[String:Terrain] = [
        " " : .none,
        "." : .grassland,
        "," : .prairie,
        "h" : .hills,
        "d" : .desert,
        "M" : .mountain,
        "o" : .ocean,
        "c" : .coastal,
    ]
    
    static var translationfromTerrain:[Terrain:String] = [
        .none: " ",
        .grassland:".",
        .prairie:",",
        .hills:"h",
        .desert:"d",
        .mountain: "M",
        .ocean: "o",
        .coastal: "c",
    ]
    
    static var nameToTerrain:[String:Terrain] = [
        "none" : .none,
        "grassland" : .grassland,
        "prairie" : .prairie,
        "hills" : .hills,
        "desert" : .desert,
        "mountain" : .mountain,
        "mountains" : .mountain,
        "ocean" : .ocean,
        "coastal" : .coastal,
    ]
    
    static var nameFromTerrain:[Terrain:String] = [
        .none : "none",
        .grassland:"grassland",
        .prairie:"prairie",
        .hills:"hills",
        .desert:"desert",
        .mountain: "mountain",
        .ocean: "ocean",
        .coastal: "coastal",
    ]
    
    static func terrainToCode(terrain: Terrain) -> String {
        translationfromTerrain[terrain]!    }
    
    static func codeToTerrain(code: String) -> Terrain? {
        Terrain.translationToTerrain[code]
    }

    case none
    case grassland, prairie, hills, desert, mountain, ocean, coastal
}
