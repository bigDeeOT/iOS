//
//  Offer.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/13/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation

class Offer {
    var driver: User?
    var date: Date?
    var eta: String?
    var comment: String?
    var unique: String?
    
    init (user: User, comment: String, date: Date) {
        driver = user
        self.comment = comment
        self.date = date
    }
    init() {
        self.date = Date()
    }
}
