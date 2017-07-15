//
//  RequestPageViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/13/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class RequestPageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var requestList = [RideRequest]()
    var loadRequests = LoadRequests()
    var userName: Rider?
    var pendingRequest: RideRequest?
    
    @IBOutlet weak var addRequest: UIBarButtonItem!
    

    @IBOutlet weak var signInButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rideRequestList.delegate = self
        rideRequestList.dataSource = self
        if let pendingRequest = pendingRequest {
            loadRequests.add(request: pendingRequest)
        }
        requestList = loadRequests.get()
        if userName == nil {
            addRequest.isEnabled = false
        } else {
            signInButton.title = "Sign Out"
        }
        print(userName?.name ?? "Not Signed in yet")
    }
    
    @IBAction func signIn(_ sender: UIBarButtonItem) {
        if sender.title == "Sign In" {
        performSegue(withIdentifier: "signIn", sender: nil)
        } else {
            //user wants to logout
            sender.title = "Sign In"
            userName = nil
            addRequest.isEnabled = false
        }
        
    }
    
    @IBOutlet weak var rideRequestList: UICollectionView!
    
    var reuseIdentifier = "rideRequest"
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return requestList.count
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let cell = cell as? RideRequestCollectionViewCell {
            let rideRequest = requestList[requestList.count - 1 - indexPath.section]
            cell.rideRequest = rideRequest
            print(cell.pickUp.text ?? "")
            print(numberOfLines(rideRequest.text ?? ""))
            cell.frame.size.height = cell.frame.size.height + (20.5 * (numberOfLines(rideRequest.text!) - 1))
        }
        //cell.frame.size.height = cell.frame.size.height + 30
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let rideRequest = requestList[requestList.count - 1 - section]
        let flow = collectionViewLayout as! UICollectionViewFlowLayout
        var inset = flow.sectionInset
        inset.bottom = inset.bottom + (20.5 * (numberOfLines(rideRequest.text!) - 1))
        return inset
    }
    
    private func numberOfLines (_ text: String) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 337, height: CGFloat(integerLiteral: Int.max)))
        label.font = UIFont(name: ".SFUIText", size: 17)
        label.text = text
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label.frame.size.height / CGFloat(20.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? RideRequestCollectionViewCell {
            performSegue(withIdentifier: "rideRequestDetails", sender: cell)
        }
    }

      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddRideTableViewController {
            vc.rider = userName
        }
    }


}
