//
//  RideRequestPageTableViewCell.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/13/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class RideRequestPageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var riderName: UILabel!
    
    @IBOutlet weak var timePosted: UILabel!

    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var offerRide: UILabel!
    
    var rider: Rider? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let picURL = rider?.profilePicURL {
            DispatchQueue.global(qos: .default).async { [weak self] in
                if let imageData = NSData(contentsOf: picURL) {
                    DispatchQueue.main.async {
                        self?.profilePic.image = UIImage(data: imageData as Data)
                    }
                }
            }
        }
        if let name = rider?.name {
            riderName.text = name
        }
    }
    
    
    
    /*
 if let profileImageURL = tweet.user.profileImageURL {
 DispatchQueue.global(qos: .default).async { [weak weakSelf = self] in
 if let imageData = NSData(contentsOf: profileImageURL) {            //blocker
 DispatchQueue.main.async {
 weakSelf?.tweetProfileImageView?.image = UIImage(data: imageData as Data)
 }
 }
 }
 }
     */
}
