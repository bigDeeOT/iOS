//
//  Rider.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/13/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation

class Rider: User {
    
     override init(url: URL, name: String) {
        super.init(name: name)
        profilePicURL = url
        privilege = .rider
    }
}
