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
    
    @IBOutlet weak var message: UIImageView!
    @IBOutlet weak var editValue: UITextField!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var key: UILabel!
    var cellCanBeEdited = false
    var controller: MiddleProfileTableViewController?
    var user: User?
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        message.isHidden = true
        if key.text == "Contact" {
            message.isHidden = false
            message.isUserInteractionEnabled = true
            message.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(messageUser)))
            if controller?.profileIsForEditing == false {
                value.addGestureRecognizer(UITapGestureRecognizer(target: controller, action: #selector(MiddleProfileTableViewController.callOrText)))
                value.isUserInteractionEnabled = true
            }
        }
        if key.text == "Date Joined" {
            if value.text != nil {
                value.text = TimeAgo.get(value.text!)
            }
        }
        controller?.cellToDismissKeyboard = self
        editValue.isHidden = true
        guard cellCanBeEdited == true else {return}
        if selected == true {
            guard controller?.allowCellSelection == true else {
                controller?.allowCellSelection = true
                return
            }
            editValue.delegate = self
            if key.text == "Contact" {
                editValue.keyboardType = .numbersAndPunctuation
                message.isHidden = true
            }
            editValue.frame.size.width = value.frame.size.width
            editValue.textAlignment = .right
            controller?.addAbilityToDismissKeyboard(tapsRequired: 1)
            editValue.becomeFirstResponder()
            editValue.isHidden = false
            editValue.text = value.text
            value.isHidden = true
        }
    }

    func messageUser() {
        controller?.profileDelegate?.performSegue(withIdentifier: "messageUser", sender: user)
        controller?.profileDelegate?.navigationController?.navigationBar.isHidden = false
    }
    
    func dismissKeyboard() {
        guard cellCanBeEdited == true else {return}
        value.text = editValue.text
        editValue.text = nil
        editValue.isHidden = true
        editValue.endEditing(true)
        value.isHidden = false
        if key.text == "Contact" {
            message.isHidden = false
        }
        updateUserInfo()
    }
    
    func updateUserInfo() {
        user?.info[key.text!] = value.text!
        LoadRequests.updateUser(user: user!)
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
