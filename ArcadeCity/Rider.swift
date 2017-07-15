//
//  Rider.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/13/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation

class Rider {
    var profilePicURL: URL?
    var name: String?
    var ridesRequest: Int?
    var ridesResolved: Int?
    
     init(url: URL, name: String) {
        profilePicURL = url
        self.name = name
    }
}
