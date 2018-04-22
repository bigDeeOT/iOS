//
//  NotificationTableViewCell.swift
//  Might
//
//  Created by Dewayne Perry on 4/21/18.
//  Copyright © 2018 The University of Texas at Austin. All rights reserved.
//

import UIKit

protocol NotificationCellDelegate: AnyObject {
    func notificationsSetOn(_ on: Bool)
}

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var notifySwitch: UISwitch!
    weak var delegate: NotificationCellDelegate?
    var initializeSwitchOn = true
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        delegate?.notificationsSetOn(sender.isOn)
    }
    
    func setNotification(_ on: Bool) {
        notifySwitch.setOn(true, animated: false)
        initializeSwitchOn = on
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        notifySwitch.setOn(initializeSwitchOn, animated: false)
    }

}
