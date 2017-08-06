//
//  KeyValueTableViewCell.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/4/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class KeyValueTableViewCell: UITableViewCell, userInfoDelegate, UITextFieldDelegate {

    //@IBOutlet weak var editValue: UITextField!
    
    @IBOutlet weak var editValue: UITextField!
   // @IBOutlet weak var editValue: UITextView!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var key: UILabel!
    var cellCanBeEdited = false
    var controller: MiddleProfileTableViewController?
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        controller?.cellToDismissKeyboard = self
        editValue.isHidden = true
        guard cellCanBeEdited == true else {return}
        if selected == true {
            guard controller?.allowCellSelection == true else {
                controller?.allowCellSelection = true
                return
            }
            editValue.delegate = self
            if key.text == "Phone" {
                editValue.keyboardType = .numbersAndPunctuation
            }
            editValue.frame.origin.x = value.frame.origin.x + 17
            editValue.frame.size.width = value.frame.size.width
            editValue.textAlignment = .right
            controller?.addAbilityToDismissKeyboard(tapsRequired: 1)
            editValue.becomeFirstResponder()
            editValue.isHidden = false
            editValue.text = value.text
            value.isHidden = true
        }
    }
    
    func dismissKeyboard() {
        guard cellCanBeEdited == true else {return}
        value.text = editValue.text
        editValue.text = nil
        editValue.isHidden = true
        editValue.endEditing(true)
        value.isHidden = false
        updateUserInfo()
    }
    
    func updateUserInfo() {
        let user = RequestPageViewController.userName
        LoadRequests.gRef.child("Users").child((user?.unique)!).child(key.text!).setValue(value.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        controller?.prepareToDismissKeyboard()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            textField.selectAll(nil)
        }
        
    }    

}
