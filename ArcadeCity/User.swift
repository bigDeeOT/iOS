//
//  User.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/15/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation

class User {
    var name: String?
    var profilePicURL: URL?
    var ridesRequested = 0
    var ridesResolved = 0
    var ridesOffered = 0
    var ridesGiven = 0
    var unique: String?
    var collage: URL?
    var phone: String?
    var privilege: Privilege = .rider
    var delegate: RideDetailViewController?
    
    enum Privilege: Int {
    case banned, rider, driver, moderator, administrator
    }
    
    
    
    init(name: String) {
        self.name = name
    }
    init(url: URL, name: String) {
        self.name = name
        profilePicURL = url
    }
    init(url: String, name: String) {
        self.name = name
        profilePicURL = URL(string: url)
    }
}
