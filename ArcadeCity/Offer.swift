//
//  Offer.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/13/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation

class Offer {
    var driver: Driver?
    var date: Date?
    var eta: Int?
    
    init (d: Driver) {
        driver = d
    }
}
