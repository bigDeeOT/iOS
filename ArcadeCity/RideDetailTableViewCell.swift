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
    var controller: RideDetailViewController?
    var maxCollageSize = CGSize(width: UIScreen.main.bounds.width * 0.9, height: 175)
    
    private func updateUI() {
        name.text = offer.driver?.info["Name"]
        etaLogic()
        phone.text = offer.driver?.info["Phone"]
        comment.text = offer.comment
        date.text = TimeAgo.get(offer.date ?? Date())
        loadImage()
        comment.lineBreakMode = .byWordWrapping
        comment.numberOfLines = 0
        collage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewImage)))
        collage.isUserInteractionEnabled = true
    }
    
    func etaLogic() {
        eta.text = offer.eta
        eta.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToMap)))
        eta.isUserInteractionEnabled = true
    }
    
    func goToMap() {
        controller?.seeMapWithDrivers()
    }
    
    func viewImage() {
        print("calling performSegue to controller")
        controller?.performSegue(withIdentifier: "viewImage", sender: collage)
    }
    
    private func loadImage() {
        
        if let picture = controller?.collagePicsCache[(offer?.driver?.unique)!] {
            collage.image = picture
            print((collage?.frame.size)!)
            collage?.frame.size = ImageResize.getNewSize(currentSize: collage?.image?.size, maxSize: maxCollageSize)
            print((collage?.frame.size)!)
            return
        }
        if let url = URL(string:(offer.driver?.info["Collage URL"])!) {
            DispatchQueue.global(qos: .default).async {
                [weak self] in
                if let imageData = NSData(contentsOf: url) {
                    DispatchQueue.main.async {
                        self?.collage?.image = UIImage(data: imageData as Data)
                        print("image curent size: \((self?.collage?.image?.size)!)")
                        print("image max size: \((self?.maxCollageSize)!)")
                        self?.collage?.frame.size = ImageResize.getNewSize(currentSize: self?.collage?.image?.size, maxSize: self?.maxCollageSize)
                        print("image new size: \((self?.collage?.frame.size)!)")
                        self?.controller?.collagePicsCache[(self?.offer?.driver?.unique)!] = UIImage(data: imageData as Data)
                    }
                }
            }
        }
    }
    
}
