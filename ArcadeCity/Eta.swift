//
//  Eta.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/30/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation

class ETA {
    static let key = "AIzaSyAjcvEc8L2-EKYd38_EUhD4rit55k-XjYs"
    static var rideRequest: RideRequest?
    static func set(_ origin: String, _ rideRequest: RideRequest) {
        ETA.rideRequest = rideRequest
        let destination = rideRequest.info["Location"] ?? "Austin"
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&key=\(key)")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("something wrong with ETA class getting task")
                print(error!)
            } else {
                if let data = data  {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
                        parse(json)
                    } catch {
                        print("error with JSONSerialisation")
                    }
                } else {
                    print("json data == nil")
                }
            }
        }
        task.resume()
    }
    
    static func parse(_ json: AnyObject) {
        let routes = json["routes"] as AnyObject
        let route1 = routes[0] as AnyObject
        let legs = route1["legs"] as AnyObject
        let leg1 = legs[0] as AnyObject
        let duration = leg1["duration"] as AnyObject
        let time = duration["text"] as! String
        rideRequest?.ETA = time + " away"
    }
    
    static func shouldHideEta(_ rideRequest: RideRequest) -> Bool {
    return rideRequest.isOld ||
        (RequestPageViewController.userName?.info["Name"] == rideRequest.rider?.info["Name"]) ||
        (rideRequest.info["Show ETA"] == "False") ||
        (RequestPageViewController.userName?.info["Class"] == "Rider") ||
        (RequestPageViewController.userName?.info["Class"] == "Pending Driver")
    }
}
