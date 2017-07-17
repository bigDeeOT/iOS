//
//  RideDetailTableViewCell.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/15/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class RideDetailTableViewCell: UITableViewCell {

    var offer: Offer! {
        didSet {
            updateUI()
        }
    }

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var eta: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var collage: UIImageView!
    @IBOutlet weak var date: UILabel!
    
    private func updateUI() {
        name.text = offer.driver?.name
        eta.text = offer.eta
        phone.text = offer.driver?.phone
        comment.text = offer.comment
        date.text = "1 min ago"
        loadImage()
        comment.lineBreakMode = .byWordWrapping
        comment.numberOfLines = 0
    }
    
    private func loadImage() {
        if let url = offer.driver?.collage {
            DispatchQueue.global(qos: .default).async {
                [weak self] in
                if let imageData = NSData(contentsOf: url) {
                    DispatchQueue.main.async {
                        self?.collage?.image = UIImage(data: imageData as Data)
                        self?.collage?.layer.borderWidth = 1
                        self?.collage?.layer.borderColor = UIColor.lightGray.cgColor

                    }
                }
            }
        }
    }
}
