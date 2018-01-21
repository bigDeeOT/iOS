//
//  ListOfUsersTableViewCell.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/15/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class ListOfUsersTableViewCell: UITableViewCell {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var detailDisclosure: UIButton!
    @IBOutlet weak var doc: UIImageView!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var name: UILabel!
    var cacheNumbers = ["Rider":0,"Driver":1,"Moderator":2,"Admin":3,"Banned":4,"Pending Driver":5]
    var cacheNumber = 0
    var controller: ListOfUsersViewController?
    var user: User? {
        didSet {
            cacheNumber = cacheNumbers[(user?.info["Class"])!]!
            name.text = user?.info["Name"]
            status.text = user?.info["Class"]
            detailDisclosureLogic()
            driverDocsLogic()
            setDriverDocs()
            loadImage()
        }
    }
    
    private func driverDocsLogic() {
        let viewerClass = RequestPageViewController.userName?.info["Class"]
        doc.isHidden = false
        if (viewerClass != "Moderator") && (viewerClass != "Admin") {
            doc.isHidden = true
        }
        if viewerClass == "Moderator" {
            if user!.info["Class"] != "Pending Driver" {
                doc.isHidden = true
            }
        }
        if user!.info["Class"] == "Rider" {
            doc.isHidden = true
        }
    }
    
    private func detailDisclosureLogic() {
        let viewerClass = RequestPageViewController.userName?.info["Class"]
        if (viewerClass == "Moderator") {
            let userClass = user?.info["Class"]
            if (userClass == "Moderator") || (userClass == "Admin") {
                detailDisclosure.isHidden = true
            } else {
                setDetailDisclosure()
            }
        } else if (viewerClass == "Rider") || (viewerClass == "Pending Driver") || (viewerClass == "Driver")  {
            detailDisclosure.isHidden = true
        } else {
            setDetailDisclosure()
        }
    }
    
    func setDetailDisclosure() {
        detailDisclosure.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeUserClass)))
    }
    
    func setDriverDocs() {
        doc.isUserInteractionEnabled = true
        doc.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewDriverDocs)))
    }

    func loadImage() {
            if let pictureID = controller?.profilePicsCache[cacheNumber][(user?.unique)!] {
                profilePic.image = pictureID
                return
            }
            if let url = URL(string: (user?.info["Profile Pic URL"])!) {
                DispatchQueue.global(qos: .default).async {
                    [weak self] in
                    if let imageData = NSData(contentsOf: url) {
                        DispatchQueue.main.async {
                            self?.profilePic.image = UIImage(data: imageData as Data)
                            self?.profilePic.layer.cornerRadius = 4
                            self?.profilePic.layer.masksToBounds = true
                            self?.controller?.profilePicsCache[(self?.cacheNumber)!][(self?.user?.unique)!] = UIImage(data: imageData as Data)
                        }
                    }
                }
            } else {
                print("invalid profile pic url")
            }
    }
    
    func changeUserClass() {
        controller?.performSegue(withIdentifier: "changeUserClass", sender:
            user)
    }
    
    func viewDriverDocs() {
        controller?.performSegue(withIdentifier: "showDriverDocs", sender: user)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected == true {
            controller?.performSegue(withIdentifier: "goToUserProfile", sender: user)
        }
    }

}
