//
//  RGBA32.swift
//  Character Tool
//
//  Created by Eric Russell on 2/25/22.
//

import Foundation
import CoreGraphics

struct RGBA32: Equatable {
    var color: UInt32

    var redComponent: UInt8 {
        return UInt8((color >> 24) & 255)
    }

    var greenComponent: UInt8 {
        return UInt8((color >> 16) & 255)
    }

    var blueComponent: UInt8 {
        return UInt8((color >> 8) & 255)
    }

    var alphaComponent: UInt8 {
        return UInt8((color >> 0) & 255)
    }

    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        let red   = UInt32(red)
        let green = UInt32(green)
        let blue  = UInt32(blue)
        let alpha = UInt32(alpha)
        color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
    }
    
    static let red     = RGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
    static let green   = RGBA32(red: 0,   green: 255, blue: 0,   alpha: 255)
    static let blue    = RGBA32(red: 0,   green: 0,   blue: 255, alpha: 255)
    static let powderblue
                       = RGBA32(red: 173, green: 216, blue: 230, alpha: 255)
    static var lightblue = RGBA32(red: 153, green:   204, blue: 255, alpha: 255)
    static let white   = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
    static let black   = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 255)
    static let magenta = RGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
    static let yellow  = RGBA32(red: 255, green: 255, blue: 0,   alpha: 255)
    static let cyan    = RGBA32(red: 0,   green: 255, blue: 255, alpha: 255)
    static let clear   = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 0)
    static let tan     = RGBA32(red: 245, green: 222, blue: 179, alpha: 255)
    static var brown = RGBA32(red: 98, green: 52, blue: 18, alpha: 255)
    static let lightyellow
                       = RGBA32(red: 255, green: 255, blue: 224, alpha: 255)
    static let lightgray = RGBA32(red: 211, green: 211, blue: 211, alpha: 255)
    

    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color == rhs.color
    }
}
