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
    var keyValues: [String: String] = [:]
    //if adding a key, also add default value below
    var keys = ["Name", "Phone", "Class", "Profile Pic URL", "Rides Requested", "Rides Resolved", "Rides Offered", "Rides Given", "Collage URL", "Bio"]
    var keysToNotDisplay: Set = ["Profile Pic URL", "Collage URL"]
    var keysOnlyForDrivers: Set = ["Rides Resolved", "Rides Offered"]
    var keysForEditing = ["Phone" : 12, "Bio" : 175]
    var keysToDisplay: [String] {
        get {
            var newKeys = keys
            var badKeys = keysToNotDisplay
            if keyValues["Class"] == "Rider" {
                badKeys = badKeys.union(keysOnlyForDrivers)
            }
            //sure it's O(n^2) but it's not like these keys will scale to large numbers
            for key in newKeys {
                if badKeys.contains(key) {
                    newKeys.remove(at: newKeys.index(of: key)!)
                }
            }
            return newKeys
        }
    }
    
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
        print("trying to put collage")
        collage = URL(string: "http://i.imgur.com/TkcP25X.jpg")
        print("collage is ", collage ?? "no collage")
        keyValues["Name"] = name
        keyValues["Profile Pic URL"] = url
        
        //hard coded default values
       // keyValues["Collage URL"] =          "http://i.imgur.com/TkcP25X.jpg"
        keyValues["Phone"] =                "469-279-0127"
        keyValues["Bio"] = "I'm just an ordinary person doing ordinary things. My favorite food truck is Arlos cause they have the best tacos. And Austin, Texas is the best city in the world 🙌😎💯"
        keyValues["Rides Requested"] =      "0"
        keyValues["Rides Resolved"] =       "0"
        keyValues["Rides Offered"] =        "0"
        keyValues["Rides Given"] =          "0"
        keyValues["Class"] =                "Rider"
        for driver in PreselectedDrivers.drivers {
            if keyValues["Name"] == driver {
                keyValues["Class"] = "Driver"
            }
        }
        
    }
    init(_ info: [String: String]) {
        for (key, value) in info {
            keyValues[key] = value
            //all of this below should be removed once whole app adapts to the keyValue system
            if key == "Name" {
                self.name = value
            }
            if key == "Profile Pic URL" {
                self.profilePicURL = URL(string: value)
            }
            if value != "Rider" {
                self.privilege = User.Privilege.driver
            }
            collage = URL(string: "http://i.imgur.com/TkcP25X.jpg")
        }
    }
    func getViewableData() -> [String:String] {
        var data = keyValues
        for (key, _) in data  {
            if keysToNotDisplay.contains(key) {
                data.removeValue(forKey: key)
            }
        }
        return data
    }
    
    func incrementVariable(_ variableToIncrease: String) {
        keyValues[variableToIncrease] = String(describing: Int(keyValues[variableToIncrease]!)! + 1)
        LoadRequests.gRef.child("Users").child(unique!).child(variableToIncrease).setValue(keyValues[variableToIncrease])
    }
    
    func decrementVariable(_ variableToIncrease: String) {
        keyValues[variableToIncrease] = String(describing: Int(keyValues[variableToIncrease]!)! - 1)
        LoadRequests.gRef.child("Users").child(unique!).child(variableToIncrease).setValue(keyValues[variableToIncrease])
    }
}





