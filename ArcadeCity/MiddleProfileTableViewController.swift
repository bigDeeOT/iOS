//
//  MiddleProfileTableViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/25/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import MessageUI

class MiddleProfileTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate {
    var data: [String : String]?
    var keys: [String]?
    var keysForEditing: [String]?
    var cellToDismissKeyboard: userInfoDelegate?
    var gestureToDismissKeyboard: UIGestureRecognizer?
    var singleTapGestureWaitsForDoubleTap: UIGestureRecognizer?
    var allowCellSelection = true
    var profileIsForEditing = true
    weak var profileDelegate: ProfileViewController?
    var collageBottomView: BottomProfileViewController?
    var spinner: UIActivityIndicatorView?
    var user: User? {
        didSet {
            updateUI()
            //this is a delegate, so when the details are done loading this page will reflect the changes
            user?.profileDetails = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collageBottomView?.containingView = profileDelegate
        tableView.separatorStyle = .none
        if profileIsForEditing == true {
            setCurrentUser()
        } else {
            tableView.allowsSelection = false
        }
        let topInset = (65 / 647) * view.frame.size.height
        tableView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 30
        if user?.info["Class"] == "Rider" || user?.info["Class"] == "Pending Driver" {
            tableView.tableFooterView?.isHidden = true
        }
        addSpinner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    func addAbilityToDismissKeyboard(tapsRequired taps: Int) {
        if taps == 2 {
            gestureToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(prepareToDismissKeyboard))
            (gestureToDismissKeyboard as! UITapGestureRecognizer).numberOfTapsRequired = 2
            gestureToDismissKeyboard?.cancelsTouchesInView = true
            tableView.allowsSelection = false
        } else {
            gestureToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(prepareToDismissKeyboard))
        }
        view.addGestureRecognizer(gestureToDismissKeyboard!)
    }
    
    func prepareToDismissKeyboard() {
        cellToDismissKeyboard?.dismissKeyboard()
        view.removeGestureRecognizer(gestureToDismissKeyboard!)
        tableView.allowsSelection = true
    }
    
    func setCurrentUser() {
        user = RequestPageViewController.userName
    }
 
    
    func updateUI() {
        data = user?.getViewableData()
        keys = user?.keysToDisplay
        keysForEditing = user?.keysForEditing
        if user?.info["Class"] != "Rider" {
            tableView.tableFooterView?.isHidden = false
        } else {
            tableView.tableFooterView?.isHidden = true
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (keys?.count)!
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        let key = keys?[indexPath.row]
        if (key == "Name") || (key == "Class") {
            cell = tableView.dequeueReusableCell(withIdentifier: "centerAligned", for: indexPath)
            cell.textLabel?.text = data?[key!]
            
        } else if key == "Bio" {
            cell = tableView.dequeueReusableCell(withIdentifier: "leftAligned", for: indexPath)
            if let cell = cell as? BioTableViewCell {
                cell.bio?.text = data?["Bio"]
               if data?[key!] == "" {cell.bio?.text = "Enter Bio"}
                cell.bio?.lineBreakMode = .byWordWrapping
                cell.bio?.numberOfLines = 0
                cell.controller = self
                cell.user = user
            }
        } else if key == "Payments" {
            cell = tableView.dequeueReusableCell(withIdentifier: "payments", for: indexPath)
            if let cell = cell as? PaymentsTableViewCell {
                if let payments = data?["Payments"] {
                cell.payments = payments
                }
                cell.controller = self
                cell.user = user
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "keyValue", for: indexPath) as? KeyValueTableViewCell
            if let cell = cell as? KeyValueTableViewCell {
                cell.key.text = key
                cell.value.text = data?[key!]
                cell.controller = self
                if (keysForEditing?.contains(key!))! {
                    if data?[key!] == "" {cell.value?.text = "Enter Info"}
                    if data?[key!] == nil {cell.value?.text = "Enter Info"}
                    cell.cellCanBeEdited = true
                }
                cell.user = user
            }
        }
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.tintColor = UIColor.clear
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BottomProfileViewController {
            vc.user = user
            collageBottomView = vc
            vc.profileIsForEditing = profileIsForEditing
        }
    }
    
    func callOrText() {
        let phone = (user?.info["Contact"])!
        guard !phone.contains("555-5555") else {return}
        let actionSheet = UIAlertController(title: "Call or Text?", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let textAction = UIAlertAction(title: "Text", style: .default) { (action) in
            guard MFMessageComposeViewController.canSendText() else {return}
            self.spinner?.startAnimating()
            let controller = MFMessageComposeViewController()
            controller.recipients = [phone]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: {self.spinner?.stopAnimating()})
        }
        let callAction = UIAlertAction(title: "Call", style: .default) { (action) in
            self.spinner?.startAnimating()
            let number = URL(string: "tel://\(phone)")
            UIApplication.shared.open(number!, options: [:], completionHandler: {bool in self.spinner?.stopAnimating()})
        }
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(textAction)
        actionSheet.addAction(callAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true, completion: nil)
    }
    
    private func addSpinner() {
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        view.addSubview(spinner!)
        spinner?.center = view.center
    }
    
    func logout() {
        FBSDKLoginManager().logOut()
        do {
            try Auth.auth().signOut()
        } catch { print("error with firebase logout") }
        RequestPageViewController.userName = nil
        LoadRequests.clear()
        tabBarController?.tabBar.isHidden = true
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "loginVC")
        present(vc, animated: true, completion: nil)
    }

}
