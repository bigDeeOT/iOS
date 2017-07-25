//
//  RequestPageTableViewCell.swift
//  ArcadeCity
//
//  Created by Guest User on 7/18/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class RequestPageTableViewCell: UITableViewCell {

    var rideRequest: RideRequest? {
        didSet {
            updateUI()
        }
    }
    
    @IBAction func offerRide(_ sender: UIButton) {
        requestPageDelegate?.segueToAddCollage(rideRequest: rideRequest!)
    }
    var requestPageDelegate: OfferRide?
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var pickUp: UILabel!
    @IBOutlet weak var timePosted: UILabel!
    @IBOutlet weak var riderName: UILabel!
    @IBOutlet weak var offerRideButton: UIButton!
    @IBOutlet weak var eta: UILabel!
    let cellWidthFactor: CGFloat = 0.92
    
    private func updateUI() {
        riderName.text = rideRequest?.rider?.name
        pickUp.text = rideRequest?.text
        pickUp.lineBreakMode = .byWordWrapping
        pickUp.numberOfLines = 0
        loadPicture()
        offerRideButtonLogic()
        etaLogic()
        timePosted.text = TimeAgo.get((rideRequest?.date)!)
    }
    
    private func etaLogic() {
        if (rideRequest?.isOld)! || (RequestPageViewController.userName?.name == rideRequest?.rider?.name) {
            eta.isHidden = true
        } else {
            eta.isHidden = false
        }
    }
    
    private func loadPicture() {
        if let url = rideRequest?.rider?.profilePicURL {
            DispatchQueue.global(qos: .default).async {
                [weak self] in
                if let imageData = NSData(contentsOf: url) {
                    DispatchQueue.main.async {
                        self?.profilePic.image = UIImage(data: imageData as Data)
                        self?.profilePic.layer.borderWidth = 1
                        self?.profilePic.layer.borderColor = UIColor.lightGray.cgColor
                    }
                }
            }
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
            if rideRequest?.state == RideRequest.State.unresolved {
                if (rideRequest?.isOld)! {
                    offerRideButton?.isHidden = true
                    return
                }
                //don't show "offer ride" to riders
                if RequestPageViewController.userName?.privilege == User.Privilege.rider {
                    offerRideButton?.isHidden = true
                } else {
                    //dont show "offer ride" if it's your own request
                    if RequestPageViewController.userName?.name == rideRequest?.rider?.name {
                        offerRideButton?.isHidden = true
                    } else {
                        offerRideButton?.isHidden = false
                    }
                }
                //don't show "offer ride" if already made offer
                if let offers = rideRequest?.offers {
                    for offer in offers {
                        if RequestPageViewController.userName?.name == offer.driver?.name {
                            offerRideButton?.setTitle("Collage Posted", for: .normal)
                            offerRideButton?.setTitleColor(UIColor.black, for: .normal)
                            offerRideButton?.isEnabled = false
                            
                        }
                    }
                }
            } else if rideRequest?.state == RideRequest.State.resolved {
                offerRideButton.isHidden = false
                offerRideButton.setTitle("#Resolved", for: .normal)
                offerRideButton.setTitleColor(UIColor.black, for: .normal)
            } else if rideRequest?.state == RideRequest.State.canceled {
                offerRideButton.isHidden = false
                offerRideButton.setTitle("#Canceled", for: .normal)
                offerRideButton.setTitleColor(UIColor.black, for: .normal)
            }
        }
    }
  
}