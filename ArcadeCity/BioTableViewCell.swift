//
//  BioTableViewCell.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/4/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

protocol userInfoDelegate {
    func dismissKeyboard()
}

class BioTableViewCell: UITableViewCell, userInfoDelegate, UITextViewDelegate {
    var controller: MiddleProfileTableViewController?
   // @IBOutlet weak var bio: UITextView!
    
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var editBio: UITextView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        controller?.cellToDismissKeyboard = self
        editBio.isHidden = true
        bio.textAlignment = .left
        editBio.textAlignment = .left
        if selected == true {
            guard controller?.allowCellSelection == true else {
                controller?.allowCellSelection = true
                return
            }
            editBio.delegate = self
            editBio.frame.origin.x = 11
            editBio.frame.origin.y = editBio.frame.origin.y + 3
            editBio.frame.size.height = bio.frame.size.height
            editBio.frame.size.width = UIScreen.main.bounds.width - 20
            controller?.addAbilityToDismissKeyboard(tapsRequired: 1)
            editBio.isHidden = false
            editBio.becomeFirstResponder()
            editBio.text = bio.text
            bio.isHidden = true
        }
    }
    
    func dismissKeyboard() {
        bio.text = editBio.text
        editBio.text = nil
        editBio.isHidden = true
        editBio.endEditing(true)
        bio.isHidden = false
    }
    
    func updateUserInfo() {
        let user = RequestPageViewController.userName
        LoadRequests.gRef.child("Users").child((user?.unique)!).child("Bio").setValue(bio.text!)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.async {
            textView.selectAll(nil)
        }
    }

}
