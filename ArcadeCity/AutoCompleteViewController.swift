//
//  AutoCompleteViewController.swift
//  Might
//
//  Created by Dewayne Perry on 3/25/18.
//  Copyright © 2018 The University of Texas at Austin. All rights reserved.
//

import UIKit
import GooglePlaces

class AutoCompleteViewController: UIViewController, GMSAutocompleteResultsViewControllerDelegate, UISearchBarDelegate {
    
    let region = "Austin, TX "
    var searchPretext: String?
    var searchVC: UISearchController?
    var searchBar: UISearchBar?
    var searchResultsVC: GMSAutocompleteResultsViewController?
    weak var addRideVC: AddRideTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultsVC = GMSAutocompleteResultsViewController()
        let southWest = CLLocationCoordinate2D(latitude: 29.657330, longitude: -98.215914)
        let northEast = CLLocationCoordinate2D(latitude: 30.546276, longitude: -97.520818)
        let box = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
        searchResultsVC?.autocompleteBounds = box
        searchResultsVC?.delegate = self
        searchVC = UISearchController(searchResultsController: searchResultsVC)
        searchVC?.searchResultsUpdater = searchResultsVC
        searchBar = searchVC?.searchBar
        searchBar?.delegate = self
        searchVC?.searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        definesPresentationContext = true
        searchBar?.text = searchPretext
        searchVC?.hidesNavigationBarDuringPresentation = false
        searchVC?.dimsBackgroundDuringPresentation = false
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = UIColor.white
        view.backgroundColor = UIColor.lightGray
        navigationController?.navigationBar.barTintColor = UIColor(red:0.16, green:0.46, blue:0.75, alpha:1.0)
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar?.becomeFirstResponder()
    }

    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        var text = place.formattedAddress!.contains(place.name) ? place.formattedAddress! : place.name + " at " + place.formattedAddress!
        text = text.replacingOccurrences(of: ", USA", with: "")
        text = text.replacingOccurrences(of: region, with: "")
        text = text.substring(to: text.index(text.endIndex, offsetBy: -6))
        if text.hasSuffix(",") {
            text = text.substring(to: text.index(text.endIndex, offsetBy: -1))
        }
        addRideVC?.autoCompleteClicked(text)
        addRideVC?.dismiss(animated: true, completion: nil)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        addRideVC?.dismiss(animated: true, completion: nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        addRideVC?.autoCompleteCanceled()
    }

}
