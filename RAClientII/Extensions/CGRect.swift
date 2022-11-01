//
//  CGRect.swift
//  OldRAClient
//
//  Created by Eric Russell on 5/1/22.
//

import CoreGraphics

extension CGRect {
    init(origin: CGPoint, dx: CGFloat, dy: CGFloat) {
        self.init(x: origin.x, y: origin.y, width: dx * 2, height: dy * 2)
    }
}
