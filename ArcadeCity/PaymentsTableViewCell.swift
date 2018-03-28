//
//  PaymentsTableViewCell.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/5/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit
import Firebase

class PaymentsTableViewCell: UITableViewCell, userInfoDelegate {
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cash: UIImageView!
    @IBOutlet weak var creditCard: UIImageView!
    @IBOutlet weak var venmo: UIImageView!
    @IBOutlet weak var payPal: UIImageView!
    @IBOutlet weak var squareCash: UIImageView!
    var controller: MiddleProfileTableViewController?
    var paymentOptions: [String : (UIImageView, UIGestureRecognizer)]?
    var toggleGesture: UIGestureRecognizer?
    var user: User?
    let paymentIndex = ["Credit Card", "Venmo", "PayPal", "Square Cash"]
    var payments = "cash"
    var venmoName: String?
    var paypalName: String?
    var squareCashName: String?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setImages()
        showDriversAvailablePayments()
        if payments == "" {payments = "cash"}
        if selected == true {
            cellTitle.text = "Double tap to save"
            setupClickingOutsideOfCell()
            allowDriverToTogglePaymentOptions()
            highlightPaymentsDriverSelected()
        }
        if controller?.profileIsForEditing == false {
            setupViewingOfUsernames()
        }
    }
    
    private func setupViewingOfUsernames() {
        paymentOptions = [
            paymentIndex[0]           : (self.creditCard, UITapGestureRecognizer(target: self, action: nil)),
            paymentIndex[1]           : (self.venmo, UITapGestureRecognizer(target: self, action: #selector(viewUserName(_:)))),
            paymentIndex[2]           : (self.payPal, UITapGestureRecognizer(target: self, action: #selector(viewUserName(_:)))),
            paymentIndex[3]           : (self.squareCash, UITapGestureRecognizer(target: self, action: #selector(viewUserName(_:))))
        ]
        for (_,(payment, toggleGesture)) in paymentOptions! {
            payment.addGestureRecognizer(toggleGesture)
            payment.isUserInteractionEnabled = true
        }
    }
    
    func viewUserName(_ sender: AnyObject) {
        let paymentName = paymentIndex[sender.view.tag]
        guard let username = user?.info[paymentName + "userName"] else {return}
        guard username != ""  else {return}
        let message = "\(user?.info["Name"] ?? "n.a")'s \(paymentName) username has been copied to your clipboard"
        let alertController = UIAlertController(title: username, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        controller?.present(alertController, animated: true, completion: nil)
        UIPasteboard.general.string = username
    }
    
    private func setupClickingOutsideOfCell() {
        controller?.cellToDismissKeyboard = self
        controller?.addAbilityToDismissKeyboard(tapsRequired: 2)
    }
    
    private func setImages() {
        cash.image = UIImage(named: "cash")
        creditCard.image = UIImage(named: "creditCard")
        creditCard.tag = 0
        venmo.image = UIImage(named: "venmo")
        venmo.tag = 1
        payPal.image = UIImage(named: "payPal")
        payPal.tag = 2
        squareCash.image = UIImage(named: "squareCash")
        squareCash.tag = 3
    }
    
    private func highlightAllPayments() {
        cash.alpha = 1
        cash.isHidden = false
        creditCard.alpha = 1
        creditCard.isHidden = false
        venmo.alpha = 1
        venmo.isHidden = false
        payPal.alpha = 1
        payPal.isHidden = false
        squareCash.alpha = 1
        squareCash.isHidden = false
    }
    
    private func showDriversAvailablePayments() {
        highlightAllPayments()
        if !payments.contains("Credit Card") {creditCard.isHidden = true}
        if !payments.contains("Venmo") {venmo.isHidden = true}
        if !payments.contains("PayPal") {payPal.isHidden = true}
        if !payments.contains("Square Cash") {squareCash.isHidden = true}
    }
    
    private func highlightPaymentsDriverSelected() {
        highlightAllPayments()
        if !payments.contains("Credit Card") {creditCard.alpha = 0.2}
        if !payments.contains("Venmo") {venmo.alpha = 0.2}
        if !payments.contains("PayPal") {payPal.alpha = 0.2}
        if !payments.contains("Square Cash") {squareCash.alpha = 0.2}
    }
    
    private func allowDriverToTogglePaymentOptions() {
        paymentOptions = [
            paymentIndex[0]          : (self.creditCard, UITapGestureRecognizer(target: self, action: #selector(togglePaymentOption(_:)))),
            paymentIndex[1]          : (self.venmo, UITapGestureRecognizer(target: self, action: #selector(togglePaymentOption(_:)))),
            paymentIndex[2]          : (self.payPal, UITapGestureRecognizer(target: self, action: #selector(togglePaymentOption(_:)))),
            paymentIndex[3]          : (self.squareCash, UITapGestureRecognizer(target: self, action: #selector(togglePaymentOption(_:))))
        ]
        for (_,(payment, toggleGesture)) in paymentOptions! {
            payment.addGestureRecognizer(toggleGesture)
            payment.isUserInteractionEnabled = true
        }
    }
    
    private func removeToggleGestures() {
        for (_,(payment, toggleGesture)) in paymentOptions! {
            payment.removeGestureRecognizer(toggleGesture)
        }
    }
    
    func togglePaymentOption(_ sender: AnyObject) {
        let tag = sender.view!.tag
        let paymentName = paymentIndex[tag]
        if payments.contains(paymentName) {
            payments = payments.replacingOccurrences(of: paymentName, with: "")
            highlightPaymentsDriverSelected()
        } else {
            if paymentName == "Credit Card" {
                payments = payments + paymentName
                highlightPaymentsDriverSelected()
            } else {
                turnOnPaymentAndEnterUserName(paymentName)
            }
        }
    }
    
    func turnOnPaymentAndEnterUserName(_ paymentName: String) {
        let paymentUserName = user?.info[paymentName + "userName"]
        let title = "Enter your " + paymentName + " username"
        let actionSheet = UIAlertController(title: nil , message: title, preferredStyle: .alert)
        actionSheet.addTextField { (textField) in
            textField.placeholder = "Enter username"
            textField.text = paymentUserName
        }
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            guard let newPaymentUsername = actionSheet.textFields?[0].text else { return }
            guard !newPaymentUsername.isEmpty else {return}
            self.payments = self.payments + paymentName
            self.user?.info[paymentName + "userName"] = newPaymentUsername
            self.highlightPaymentsDriverSelected()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(okAction)
        actionSheet.addAction(cancelAction)
        controller?.present(actionSheet, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        removeToggleGestures()
        updateUserInfo()
        showDriversAvailablePayments()
        cellTitle.text = "Payments"
    }
    
    private func updateUserInfo() {
        user?.info["Payments"] = payments
        LoadRequests.updateUser(user: user!)
    }
    
}
