//
//  RideRequestCollectionViewCell.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/13/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class RideRequestCollectionViewCell: UICollectionViewCell {
    var delegateClass: RequestPageViewController?
    var rideRequest: RideRequest? {
        didSet {
            updateUI()
        }
    }
    @IBAction func offerRide(_ sender: UIButton) {
        //delegateClass?.segueToAddCollage(rideRequest: rideRequest!)
    }
    @IBOutlet weak var profilePic: UIImageView!

    @IBOutlet weak var pickUp: UILabel!
    @IBOutlet weak var timePosted: UILabel!
    @IBOutlet weak var riderName: UILabel!
    @IBOutlet weak var offerRideButton: UIButton!

    
    private func updateUI() {
        riderName.text = rideRequest?.rider?.name
        pickUp.text = rideRequest?.text
        pickUp.lineBreakMode = .byWordWrapping
        pickUp.numberOfLines = 0
        
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
        if RequestPageViewController.userName == nil {
            //offerRideButton?.removeFromSuperview()
        }
    }
}
