//
//  RequestPageTableViewCell.swift
//  ArcadeCity
//
//  Created by Guest User on 7/18/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class RequestPageTableViewCell: UITableViewCell, ETADelegate {

    var rideRequest: RideRequest? {
        didSet {
            updateUI()
        }
    }
    
    @IBAction func offerRide(_ sender: UIButton) {
        requestPageDelegate?.segueToAddCollage(rideRequest: rideRequest!)
    }
    var requestPageDelegate: OfferRide?
    var requestPage: RequestPageViewController?
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var pickUp: UILabel!
    @IBOutlet weak var timePosted: UILabel!
    @IBOutlet weak var riderName: UILabel!
    @IBOutlet weak var offerRideButton: UIButton!
    @IBOutlet weak var eta: UILabel!
    let cellWidthFactor: CGFloat = 0.92
    
    private func updateUI() {
        requestPage = requestPageDelegate as? RequestPageViewController
        riderName.text = rideRequest?.rider?.info["Name"]
        clickToGoToUserProfile()
        pickUp.text = rideRequest?.info["Text"]
        pickUp.lineBreakMode = .byWordWrapping
        pickUp.numberOfLines = 0
        loadPicture()
        offerRideButtonLogic()
        etaLogic()
        timePosted.text = TimeAgo.get((rideRequest?.info["Date"])!)
    }
    
    private func clickToGoToUserProfile() {
        riderName.sizeToFit()
        profilePic.isUserInteractionEnabled = true
        profilePic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToUserProfile)))
    }
    
    func goToUserProfile() {
        requestPage?.performSegue(withIdentifier: "goToUserProfile", sender: rideRequest?.rider)
    }
    
    func etaIsReady(text etaText: String, value etaValue: Int) {
        rideRequest?.ETA = etaText + " away"
        etaLogic()
        requestPage?.rideRequestList?.reloadData()
    }
    
     func etaLogic() {
        if ETA.shouldHideEta(rideRequest!)  {
            eta.isHidden = true
        } else {
            eta.isHidden = false
            eta.text = rideRequest?.ETA
        }
    }
    
    private func loadPicture() {
        //debuggingPicture()
        let unique = rideRequest?.rider?.unique
        if let pictureID = requestPage?.profilePicsCache[(rideRequest?.rider?.unique)!] {
            profilePic.image = pictureID
            return
        }
        profilePic.image = #imageLiteral(resourceName: "profilePicPlaceHolder")
        guard let profilePicURL = rideRequest?.rider?.info["Profile Pic URL"] else {return}
        if let url = URL(string: profilePicURL) {
            DispatchQueue.global(qos: .default).async {
                [weak self] in
                if let imageData = NSData(contentsOf: url) {
                    DispatchQueue.main.async {
                        guard unique == self?.rideRequest?.rider?.unique else {return}
                        self?.profilePic.image = UIImage(data: imageData as Data)
                        self?.profilePic.layer.cornerRadius = 4
                        self?.profilePic.layer.masksToBounds = true
                        self?.requestPage?.profilePicsCache[(self?.rideRequest?.rider?.unique)!] = UIImage(data: imageData as Data)
                    }
                }
            }
            } else {
            print("invalid profile pic url")
        }
    }
    
    private func debuggingPicture() {
        print((rideRequest?.unique)! + "\n")
        print(pickUp.text! + "\n")
        if requestPage != nil {
            print("requestPage exists\n")
            
        } else {
            print("NO requestPage ***\n")
        }
        if rideRequest != nil {
            print("rideRequest exists\n")
            
        } else {
            print("NO rideRequest ***\n")
        }
    }
    
    private func offerRideButtonLogic() {
        offerRideButton?.setTitle("Offer Ride", for: .normal)
        offerRideButton?.isEnabled = true
        offerRideButton?.isHidden = false
        offerRideButton?.setTitleColor(UIColor(red:0.05, green:0.29, blue:0.59, alpha:1.0), for: .normal)
        if RequestPageViewController.userName == nil {
            //don't show offer button if not signed in
            offerRideButton?.isHidden = true
        } else {
            if rideRequest?.info["State"] == "Unresolved" {
                //can't post if you don't have a collage
                if (RequestPageViewController.userName?.info["Collage URL"] == nil) {
                    offerRideButton?.isHidden = true
                    return
                }
                if (rideRequest?.isOld)! {
                    offerRideButton?.isHidden = true
                    return
                }
                //don't show "offer ride" to riders
                if (RequestPageViewController.userName?.info["Class"] == "Rider") ||
                    (RequestPageViewController.userName?.info["Class"] == "Pending Driver") {
                    offerRideButton?.isHidden = true
                } else {
                    //dont show "offer ride" if it's your own request
                    if RequestPageViewController.userName?.info["Name"] == rideRequest?.rider?.info["Name"] {
                        offerRideButton?.isHidden = true
                    } else {
                        offerRideButton?.isHidden = false
                    }
                }
                //don't show "offer ride" if already made offer
                if let offers = rideRequest?.offers {
                    for offer in offers {
                        if RequestPageViewController.userName?.info["Name"] == offer.driver?.info["Name"] {
                            offerRideButton?.setTitle("Collage Posted", for: .normal)
                            offerRideButton?.setTitleColor(UIColor.black, for: .normal)
                            offerRideButton?.isEnabled = false
                        }
                    }
                }
            } else if rideRequest?.info["State"] == "#Resolved" {
                offerRideButton.isHidden = false
                offerRideButton.setTitle("#Resolved", for: .normal)
                offerRideButton.setTitleColor(UIColor.black, for: .normal)
            } else if rideRequest?.info["State"] == "#Canceled" {
                offerRideButton.isHidden = false
                offerRideButton.setTitle("#Canceled", for: .normal)
                offerRideButton.setTitleColor(UIColor.black, for: .normal)
            }
        }
    }
  
}
