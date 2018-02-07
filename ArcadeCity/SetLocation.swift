//
//  Location.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/30/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//
import UIKit
import Foundation
import CoreLocation

class SetLocation: UIViewController, CLLocationManagerDelegate {
    var manager = CLLocationManager()
    var latLog: String?
    var rideRequest: RideRequest?
    var destination: String?
    var etaDelegate: ETADelegate?
    
    func set() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func setETA(to dest: String?, for delegate: ETADelegate?) {
        destination = dest
        etaDelegate = delegate
        set()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        latLog = String(describing: latitude) + "," + String(describing: longitude)
        manager.stopUpdatingLocation()
        if etaDelegate != nil {
            ETA.set(latLog!, destination!, etaDelegate!)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
