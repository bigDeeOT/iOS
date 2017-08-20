//
//  Requirement.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/19/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation

class Document {
    var title: String?
    var type: String?
    var index: Int?
    
    init(title: String, type: String, index: Int) {
        self.title = title
        self.type = type
        self.index = index
    }
}
