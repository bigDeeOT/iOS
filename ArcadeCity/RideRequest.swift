//
//  RideRequest.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/13/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation

class RideRequest {
    var rider: Rider?
    var date: Date?
    var offers: [Offer]?
    var state: State?
    var location: String?
    var text: String?
    
    enum State {
       case unresolved, resolved, canceled
    }
    
    init (r: Rider) {
        rider = r
        state = .unresolved
        offers = [Offer]()
    }
}
