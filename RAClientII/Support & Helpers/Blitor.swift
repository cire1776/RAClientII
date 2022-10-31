//
//  Blitor.swift
//  Character Tool
//
//  Created by Eric Russell on 2/25/22.
//

import Foundation

protocol Blitor {
    func blit(at offset: Int, on pixelBuffer: inout UnsafeMutablePointer<RGBA32>,value: Float,adjustValue:Bool)
    
    func blit(at offset: Int, on pixelBuffer: inout UnsafeMutablePointer<RGBA32>,value: RGBA32)
    
    func makePixel(value: Float) -> UInt8
}

extension Blitor {
    func blit(at offset: Int, on pixelBuffer: inout UnsafeMutablePointer<RGBA32>,value: Float,adjustValue:Bool = true) {
        let adjustedValue = adjustValue ? makePixel(value: value) : UInt8(value)
        
        let color = RGBA32(red: adjustedValue, green: adjustedValue, blue: adjustedValue, alpha: 255)
        pixelBuffer[offset] = color
    }
    
    func blit(at offset: Int, on pixelBuffer: inout UnsafeMutablePointer<RGBA32>,value: RGBA32) {
        
        let color = RGBA32(red: value.redComponent, green: value.greenComponent, blue: value.blueComponent, alpha: value.alphaComponent)
        pixelBuffer[offset] = color
    }
    
    func makePixel(value: Float) -> UInt8 {
        UInt8(((value + 1) / 2) * 255)
    }
}
