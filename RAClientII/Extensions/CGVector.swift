//
//  CGVector.swift
//  RAClient
//
//  Created by Eric Russell on 4/27/22.
//

import CoreGraphics

infix operator *: MultiplicationPrecedence

extension CGVector {
    static var standard: CGVector {
        CGVector(dx: 1, dy: 0)
    }
    
    static func * (lhs: CGVector, rhs: CGFloat) -> CGVector {
        CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
    }
    
    static func * (lhs: CGVector, rhs: Double) -> CGVector {
        CGVector(dx: lhs.dx * CGFloat(rhs), dy: lhs.dy * CGFloat(rhs))
    }
    
    static func * (lhs: CGVector, rhs: Int) -> CGVector {
        CGVector(dx: lhs.dx * CGFloat(rhs), dy: lhs.dy * CGFloat(rhs))
    }
    
    var magnitude: CGFloat {
        sqrt( (pow(self.dx,2) + pow(self.dy,2) ))
    }
    
    var normalized: CGVector {
        CGVector( dx: self.dx / magnitude, dy: self.dy / magnitude)
    }
    
    func dot(_ v: CGVector) -> CGFloat {
        return dx * v.dx + dy * v.dy
    }

    func cross(_ v: CGVector) -> CGFloat {
        return dx * v.dy - dy * v.dx
    }

    
    func angle(with v: CGVector = CGVector(dx: 0, dy: 1)) -> CGFloat {
        if self == v { return 0 }

        let t1 = normalized
        let t2 = v.normalized
        let cross = t1.cross(t2)
        let dot = max(-1, min(1, t1.dot(t2)))

        return atan2(cross, dot)
    }
}

