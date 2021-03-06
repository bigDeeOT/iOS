//
//  RideRequest.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/13/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation

class RideRequest {
    var rider: User?
    var date: Date?
    var offers: [Offer]?
    var location: String?
    var text: String?
    var showETA: Bool = true
    var ETA: String?
    var unique: String?
    var delegate: RideDetailViewController?
    var info: [String: String] = [:]
    var resolvedBy: User? {
        didSet {
            if resolvedBy != nil {
                state = State.resolved
            } else {
                state = State.unresolved
            }
        }
    }
    var isOld: Bool {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
            let dateValue = dateFormatter.date(from: info["Date"]!)
            if Date().timeIntervalSince(dateValue!) > 60*20 {
                return true
            }
            return false
        }
    }
    
    enum State: Int {
       case unresolved, resolved, canceled
    }
    var state: State = .unresolved
    
    init (rider: User) {
        self.rider = rider
        state = .unresolved
        offers = [Offer]()
    }
    init () {
        self.rider = RequestPageViewController.userName
        offers = [Offer]()
    }
    
}
