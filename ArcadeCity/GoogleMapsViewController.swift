//
//  GoogleMapsViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/1/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class GoogleMapsViewController: UIViewController, GMSMapViewDelegate {

    var latitude: String!
    var longitude: String!
    var showDrivers = false
    var mapView: GMSMapView!
    var rideRequest: RideRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createMap()
        createRiderMarker()
        if showDrivers {
            for offer in (rideRequest.offers)! {
                createDriverMarker(offer)
            }
        }
    }
    //test with 30.371502,-97.758357
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if showDrivers == false {
            UIApplication.shared.open(URL(string:"comgooglemaps://?saddr=&daddr=\(latitude!),\(longitude!)&directionsmode=driving")!, options: [:], completionHandler: nil)
            return true
        }
        return false
    }

    func createMap() {
        setLatitudeLongitude((rideRequest?.info["Location"])!)
        let camera = GMSCameraPosition.camera(withLatitude: Double(latitude)!, longitude: Double(longitude)!, zoom: 11.0)
        GMSServices.provideAPIKey("AIzaSyAJxvbSc0wd1jJYCpqEC0iAB4PPlMu03UE")
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        mapView.delegate = self
    }
    
    func createRiderMarker() {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!)
        marker.title = rideRequest.rider?.info["Name"]
        marker.snippet = "Needs a ride"
        marker.icon = UIImage(named: "logoMaps")
        marker.map = mapView
    }
    
    func createDriverMarker(_ offer: Offer) {
        setLatitudeLongitude(offer.location!)
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!)
        marker.title = offer.driver?.info["Name"]
        marker.snippet = offer.eta!
        marker.map = mapView
    }
    
    func setLatitudeLongitude(_ location: String) {
        var indexOfComma = location.startIndex
        while (indexOfComma != location.endIndex) {
            if location[indexOfComma] == "," {break}
            indexOfComma = location.index(after: indexOfComma)
        }
        latitude = location.substring(to: location.index(before: indexOfComma))
        longitude = location.substring(from: location.index(after: indexOfComma))
    }

}
