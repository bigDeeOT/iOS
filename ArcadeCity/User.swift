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
    var unique: String?
    var collage: URL?
    var phone: String?
    
    enum Privilege: Int {
    case banned, rider, driver, moderator, administrator
    }
    
    var privilege: Privilege = .rider
    
    init(name: String) {
        self.name = name
    }
    init(url: URL, name: String) {
        self.name = name
        profilePicURL = url
    }
}
