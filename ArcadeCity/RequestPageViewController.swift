//
//  RequestPageViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/13/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class RequestPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, OfferRide {
    
    var requestList = [RideRequest]()
    var loadRequests = LoadRequests()
    static var userName: User?
    var pendingRequest: RideRequest?
    var cellWasViewed = [Bool]()
     @IBOutlet weak var rideRequestList: UITableView!
    @IBOutlet weak var addRequest: UIBarButtonItem!
    @IBOutlet weak var signInButton: UIBarButtonItem!
    var reuseIdentifier = "rideRequest"
    var tableBackgroundColor = UIColor(red:0.83, green:0.84, blue:0.87, alpha:1.0)
    //var tableBackgroundColor = UIColor(red:0.14, green:0.19, blue:0.26, alpha:1.0)
    var justSignedIn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rideRequestList.delegate = self
        rideRequestList.dataSource = self
        if let pendingRequest = pendingRequest {
            loadRequests.add(request: pendingRequest)
        }
        requestList = loadRequests.get()
        updateSignInButton()
        print(RequestPageViewController.userName?.name ?? "Not Signed in yet")
        let image = UIImage(named: "logo")
        navigationItem.titleView = UIImageView(image: image)
        self.rideRequestList.rowHeight = UITableViewAutomaticDimension
        self.rideRequestList.estimatedRowHeight = 128
        self.view.backgroundColor = tableBackgroundColor
        //navigationController?.navigationBar.isTranslucent = false
        //navigationController?.navigationBar.barTintColor = UIColor(red:0.14, green:0.19, blue:0.26, alpha:1.0)
        rideRequestList.backgroundColor = tableBackgroundColor
    }
    
    private func updateSignInButton() {
        if RequestPageViewController.userName == nil {
            addRequest.isEnabled = false
            
        } else {
            signInButton.title = "Sign Out"
            addRequest.isEnabled = true
            //addRequest.tintColor = UIColor.white
        }
        //signInButton.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateSignInButton()
        rideRequestList.reloadData()
    }
    
    @IBAction func signIn(_ sender: UIBarButtonItem) {
        if sender.title == "Sign In" {
        performSegue(withIdentifier: "signIn", sender: nil)
        } else {
            //user wants to logout
            sender.title = "Sign In"
            RequestPageViewController.userName = nil
            addRequest.isEnabled = false
            rideRequestList.reloadData()
        }
    }
    
    /* Spacing between cells*/
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 15
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 15))
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 15))
        view.backgroundColor = UIColor.clear
        return view
    }
    /* End of Spacing between cells*/
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return requestList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if let cell = cell as? RequestPageTableViewCell {
            let rideRequest = requestList[requestList.count - 1 - indexPath.section]
            cell.rideRequest = rideRequest
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.requestPageDelegate = self
        }

        return cell
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RequestPageTableViewCell {
            if RequestPageViewController.userName != nil {
                performSegue(withIdentifier: "rideRequestDetails", sender: cell)
            }
        }
    }
    
    func segueToAddCollage(rideRequest: RideRequest) {
        if (rideRequest.state == RideRequest.State.unresolved) {
            performSegue(withIdentifier: "postCollage", sender: rideRequest)
        }
    }
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RideDetailViewController {
            if let cell = sender as? RequestPageTableViewCell {
                vc.rideRequest = cell.rideRequest
            }
        }
        if let vc = segue.destination as? PostCollageViewController {
            if let request = sender as? RideRequest {
                vc.rideRequest = request
            }
        }
        
    }

    @IBAction func unwindToRequestPage(segue: UIStoryboardSegue) {
        
    }

}

protocol OfferRide {
    func segueToAddCollage(rideRequest: RideRequest)
}

//glitches - when someone resolves a ride, then unresolves it, when another user signs in, it shows still resolved. 
