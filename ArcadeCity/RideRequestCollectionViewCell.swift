//
//  RideRequestCollectionViewCell.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/13/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class RideRequestCollectionViewCell: UICollectionViewCell {
    
    var rideRequest: RideRequest? {
        didSet {
            updateUI()
        }
    }
    @IBAction func offerRide(_ sender: UIButton) {
        //segue
        print(rideRequest?.rider?.name ?? "unknown ride request")
    }
    @IBOutlet weak var profilePic: UIImageView!

    @IBOutlet weak var pickUp: UILabel!
    @IBOutlet weak var timePosted: UILabel!
    @IBOutlet weak var riderName: UILabel!
    
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
                    }
                }
            }
        }
    }
}
