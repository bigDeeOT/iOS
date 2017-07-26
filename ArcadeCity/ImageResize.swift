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
        var maxSizeScale = CGFloat(1)
        var scale = CGFloat(1)
        
        //Scale factor if both sizes are portrait or both sizes are landscape
        
        if ((current.width/current.height < 1) && (max.width/max.height < 1)) || ((current.height/current.width < 1) && (max.height/max.width < 1)) {
            maxSizeScale = max.width / max.height
            if maxSizeScale > 1 {maxSizeScale = 1 / maxSizeScale}
        }
 
        
        print("maxSizeScale is ", maxSizeScale)
        //if image is already smaller, don't resize
        if (current.width <= max.width) && (current.height <= max.height) {
            return current
        }
        if current.width >= current.height {
            if max.width > current.width {
                scale = max.height / current.height
            } else {
                scale = max.width / current.width
            }
            print("scale is ", scale)
            return CGSize(width: current.width * scale * maxSizeScale, height: current.height * scale * maxSizeScale)
        }
        if current.width < current.height {
            if max.height > current.height {
                scale = max.width / current.width
            } else  {
                scale = max.height / current.height
            }
            print("scale is ", scale)
            return CGSize(width: current.width * scale * maxSizeScale, height: current.height * scale * maxSizeScale)
        }
        return current
    }
}
