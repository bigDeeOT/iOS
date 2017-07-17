//
//  Driver.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/13/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation

class Driver: User {
    override init (name: String) {
        super.init(name: name)
        privilege = .driver
    }
}
