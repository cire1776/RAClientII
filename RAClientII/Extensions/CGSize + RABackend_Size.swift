//
//  CGSize.swift
//  RAClientII
//
//  Created by Eric Russell on 10/24/22.
//

import Foundation

extension CGSize {
    init(_ size: RABackend_Size) {
        self.init()
        
        self.width = size.width
        self.height = size.height
    }
}
