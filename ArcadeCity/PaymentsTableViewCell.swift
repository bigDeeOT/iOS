//
//  PaymentsTableViewCell.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/5/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class PaymentsTableViewCell: UITableViewCell, userInfoDelegate {
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cash: UIImageView!
    @IBOutlet weak var creditCard: UIImageView!
    @IBOutlet weak var venmo: UIImageView!
    @IBOutlet weak var payPal: UIImageView!
    @IBOutlet weak var squareCash: UIImageView!
    var controller: MiddleProfileTableViewController?
    var paymentOptions: [String : (UIImageView, UIGestureRecognizer)]?
    var paymentOptionsIndex: [String]?
    var toggleGesture: UIGestureRecognizer?
    var user: User?
    
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
        paymentOptions = [
            "creditCard"    : (self.creditCard, UITapGestureRecognizer(target: self, action: #selector(togglePaymentOption(_:)))),
            "venmo"         : (self.venmo, UITapGestureRecognizer(target: self, action: #selector(togglePaymentOption(_:)))),
            "payPal"        : (self.payPal, UITapGestureRecognizer(target: self, action: #selector(togglePaymentOption(_:)))),
            "squareCash"    : (self.squareCash, UITapGestureRecognizer(target: self, action: #selector(togglePaymentOption(_:))))
        ]
        paymentOptionsIndex = ["creditCard", "venmo", "payPal", "squareCash"]
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
        if !payments.contains("creditCard") {creditCard.isHidden = true}
        if !payments.contains("venmo") {venmo.isHidden = true}
        if !payments.contains("payPal") {payPal.isHidden = true}
        if !payments.contains("squareCash") {squareCash.isHidden = true}
    }
    
    private func highlightPaymentsDriverSelected() {
        highlightAllPayments()
        if !payments.contains("creditCard") {creditCard.alpha = 0.2}
        if !payments.contains("venmo") {venmo.alpha = 0.2}
        if !payments.contains("payPal") {payPal.alpha = 0.2}
        if !payments.contains("squareCash") {squareCash.alpha = 0.2}
    }
    
    private func allowDriverToTogglePaymentOptions() {
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
        let paymentName = paymentOptionsIndex?[tag]
        if payments.contains(paymentName!) {
            payments = payments.replacingOccurrences(of: paymentName!, with: "")
        } else {
            payments = payments + paymentName!
        }
        highlightPaymentsDriverSelected()
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
       // LoadRequests.gRef.child("Users").child((user?.unique)!).child("Payments").setValue(payments)
    }
    
}
