//
//  MiddleProfileTableViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/25/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit
import Firebase

class MiddleProfileTableViewController: UITableViewController {
    var data: [String : String]?
    var keys: [String]?
    var keysForEditing: [String]?
    var cellToDismissKeyboard: userInfoDelegate?
    var gestureToDismissKeyboard: UIGestureRecognizer?
    var singleTapGestureWaitsForDoubleTap: UIGestureRecognizer?
    var allowCellSelection = true
    var profileIsForEditing = true
    var profileDelegate: ProfileViewController?
    var collageBottomView: BottomProfileViewController?
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
        tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 30
        if user?.info["Class"] == "Rider" || user?.info["Class"] == "Pending Driver" {
            tableView.tableFooterView?.isHidden = true
        }
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

}
