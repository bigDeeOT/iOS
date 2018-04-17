//
//  RideDetailTableViewCell.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/15/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit
import Firebase



class RideDetailTableViewCell: UITableViewCell {

    var offer: Offer! {
        didSet {
            updateUI()
        }
    }
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var eta: UILabel!
    @IBOutlet weak var phone: UIImageView!
    @IBOutlet weak var message: UIImageView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var collage: UIImageView!
    @IBOutlet weak var date: UILabel!
    weak var controller: RideDetailViewController?
    var maxCollageSize = CGSize(width: UIScreen.main.bounds.width * 0.9, height: 225)
    
    private func updateUI() {
        name.text = offer.driver?.info["Name"]
        clickToGoToUserProfile()
        etaLogic()
        comment.text = offer.comment
        date.text = TimeAgo.get(offer.date ?? Date())
        loadImage()
        comment.lineBreakMode = .byWordWrapping
        comment.numberOfLines = 0
        collage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewImage)))
        collage.isUserInteractionEnabled = true
        message.isUserInteractionEnabled = true
        message.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(messageUser)))
        guard !(offer.driver?.info["Contact"])!.contains("555-5555") else {phone.isHidden = true; return}
        phone.isUserInteractionEnabled = true
        phone.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(callOrText)))
    }
    
    func callOrText() {
       controller?.callOrText(name.text!, (offer.driver?.info["Contact"])!)
    }
    
    private func clickToGoToUserProfile() {
        name.sizeToFit()
        name.isUserInteractionEnabled = true
        name.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToUserProfile)))
    }
    
    func goToUserProfile() {
        controller?.performSegue(withIdentifier: "goToUserProfile", sender: offer?.driver)
    }
    
    func messageUser() {
        controller?.performSegue(withIdentifier: "messageUser", sender: offer.driver)
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
            collage?.frame.size = ImageResize.getNewSize(currentSize: collage?.image?.size, maxSize: maxCollageSize)
            return
        }
        if let url = URL(string:(offer.driver?.info["Collage URL"])!) {
            DispatchQueue.global(qos: .default).async {
                [weak self] in
                if let imageData = NSData(contentsOf: url) {
                    DispatchQueue.main.async {
                        self?.collage?.image = UIImage(data: imageData as Data)
                        self?.collage?.frame.size = ImageResize.getNewSize(currentSize: self?.collage?.image?.size, maxSize: self?.maxCollageSize)
                        self?.controller?.collagePicsCache[(self?.offer?.driver?.unique)!] = UIImage(data: imageData as Data)
                        self?.collage.layer.cornerRadius = 4
                        self?.collage.layer.masksToBounds = true
                    }
                } else {
                    //if driver changes collage, update the url
                    LoadRequests.gRef.child("Users/\((self?.offer.driver?.unique)!)/Collage URL").observeSingleEvent(of: .value, with: { (snap) in
                        self?.offer.driver?.info["Collage URL"] = snap.value as? String
                        self?.controller?.collagePicsCache.removeValue(forKey: (self?.offer?.driver?.unique)!)
                        self?.controller?.reload()
                    })
                }
            }
        }
    }
    
}
