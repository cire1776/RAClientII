//
//  SKScene.swift
//  RAClient
//
//  Created by Eric Russell on 4/23/22.
//

import SpriteKit
import MetalKit

public extension SKNode {
    func toImage() -> UIImage? {
        guard let texture = scene?.view?.texture(from: self) else { return nil }
        let image = texture.cgImage()
        return UIImage(cgImage: image)
    }
}
