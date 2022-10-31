//
//  CGFloat.swift
//  Royal Ambition
//
//  Created by Eric Russell on 2/11/22.
//

import CoreGraphics

public extension CGFloat {
    var isOdd: Bool {
        return Int(self) % 2 == 1
    }
    
    var isEven: Bool {
        return Int(self) % 2 == 0
    }
}
