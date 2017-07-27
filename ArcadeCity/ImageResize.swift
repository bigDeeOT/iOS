//
//  ImageResize.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/25/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class ImageResize {
    static func getNewSize(currentSize current: CGSize!, maxSize max: CGSize!) -> CGSize {
        var newSize: CGSize
        var scale = CGFloat(1)
        if (current.width <= max.width) && (current.height <= max.height) {
            return current
        }
        if current.width > max.width {
            scale = max.width / current.width
            newSize = CGSize(width: current.width * scale, height: current.height * scale)
            if newSize.height > max.height {
                scale = max.height / newSize.height
                newSize = CGSize(width: newSize.width * scale, height: newSize.height * scale)
            }
            return newSize
        }
        if current.height > max.height {
            scale = max.height / current.height
            newSize = CGSize(width: current.width * scale, height: current.height * scale)
            if newSize.width > max.width {
                scale = max.width / newSize.width
                newSize = CGSize(width: newSize.width * scale, height: newSize.height * scale)
            }
            return newSize
        }
        return current
    }
}
