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
    var collage: URL?
    var phone: String?
    var privilege: Privilege = .rider
    var delegate: RideDetailViewController?
    var profileDetails: MiddleProfileTableViewController?
    var info: [String: String] = [:]
    var unique: String? {
        didSet {
            info["Unique"] = unique
        }
    }
    var keys = ["Name", "Class", "Bio", "Phone", "Car", "Payments", "Date Joined", "Profile Pic URL", "Rides Requested", "Rides Taken", "Rides Offered", "Rides Given", "Collage URL"]
    var keysToNotDisplay: Set = ["Profile Pic URL", "Collage URL"]
    var keysOnlyForDrivers: Set = ["Rides Given", "Rides Offered", "Car", "Phone"]
    var keysForEditing = ["Phone", "Bio", "Car", "Payments"]
    static let defaultBio = "I'm just an ordinary person doing ordinary things. \nClick to add your own bio\n😎💥"
    var keysToDisplay: [String] {
        get {
            var newKeys = keys
            var badKeys = keysToNotDisplay
            if info["Class"] == "Rider" || info["Class"] == "Pending Driver" {
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
        info["Name"] = name
        info["Profile Pic URL"] = url
        
        //hard coded default values
       // info["Collage URL"] =          "http://i.imgur.com/TkcP25X.jpg"
        info["Phone"] =                "512-867-5309"
        info["Bio"] = User.defaultBio
        info["Rides Requested"] =      "0"
        info["Rides Taken"] =          "0"
        info["Rides Offered"] =        "0"
        info["Rides Given"] =          "0"
        info["Class"] =                "Rider"
        info["Class"] =                "Rider"
        info["Car"]  =                 "Color Make Model"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
        let date = dateFormatter.string(from: Date())
        info["Date Joined"] = date
        for driver in PreselectedDrivers.drivers {
            if info["Name"] == driver {
                info["Class"] = "Driver"
            }
        }
        for mod in PreselectedModerators.mods {
            if info["Name"] == mod {
                info["Class"] = "Moderator"
            }
        }
        for admin in PreselectedAdmins.admins {
            if info["Name"] == admin {
                info["Class"] = "Admin"
            }
        }
        
    }
    init(_ information: [String: String]) {
        for (key, value) in information {
            info[key] = value
        }
        unique = info["Unique"]
        guard info["Date Joined"] == nil else {return}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
        let date = dateFormatter.string(from: Date())
        info["Date Joined"] = date
    }
    func getViewableData() -> [String:String] {
        var data = info
        for (key, _) in data  {
            if keysToNotDisplay.contains(key) {
                data.removeValue(forKey: key)
            }
        }
        return data
    }
    
    func incrementVariable(_ variableToIncrease: String) {
        info[variableToIncrease] = String(describing: Int(info[variableToIncrease]!)! + 1)
        LoadRequests.updateUser(user: self)
        //LoadRequests.gRef.child("Users").child(unique!).child(variableToIncrease).setValue(info[variableToIncrease])
        profileDetails?.updateUI()
    }
    
    func decrementVariable(_ variableToDecrease: String) {
        info[variableToDecrease] = String(describing: Int(info[variableToDecrease]!)! - 1)
        LoadRequests.updateUser(user: self)
        //LoadRequests.gRef.child("Users").child(unique!).child(variableToDecrease).setValue(info[variableToDecrease])
        profileDetails?.updateUI()
    }
}





