//
//  UIImage.swift
//  Royal Ambition
//
//  Created by Eric Russell on 2/5/22.
//

import UIKit

extension UIImage {
    static func coloredImage(image: UIImage?, color: UIColor) -> UIImage? {

        guard let image = image else {
            return nil
        }

        let backgroundSize = image.size
        UIGraphicsBeginImageContextWithOptions(backgroundSize, false, UIScreen.main.scale)

        let ctx = UIGraphicsGetCurrentContext()!

        var backgroundRect=CGRect()
        backgroundRect.size = backgroundSize
        backgroundRect.origin.x = 0
        backgroundRect.origin.y = 0

        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        ctx.setFillColor(red: r, green: g, blue: b, alpha: a)
        ctx.fill(backgroundRect)

        var imageRect = CGRect()
        imageRect.size = image.size
        imageRect.origin.x = (backgroundSize.width - image.size.width) / 2
        imageRect.origin.y = (backgroundSize.height - image.size.height) / 2

        // Unflip the image
        ctx.translateBy(x: 0, y: backgroundSize.height)
        ctx.scaleBy(x: 1.0, y: -1.0)

        ctx.setBlendMode(.destinationIn)
        ctx.draw(image.cgImage!, in: imageRect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    func tint(color: UIColor, blendMode: CGBlendMode) -> UIImage {
        let drawRect = CGRect(x: 0,y: 0,width: size.width,height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        UIRectFill(drawRect)
        draw(in: drawRect, blendMode: blendMode, alpha: 1.0)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
}
