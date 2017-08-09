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
    var useGlobalUser = true
    var cellToDismissKeyboard: userInfoDelegate?
    var gestureToDismissKeyboard: UIGestureRecognizer?
    var singleTapGestureWaitsForDoubleTap: UIGestureRecognizer?
    var allowCellSelection = true
    var user: User? {
        didSet {
            updateUI()
            user?.profileDetails = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        if useGlobalUser == true {
            userListener()
        }
        tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 30
        if RequestPageViewController.userName?.info["Class"] == "Rider" {
            tableView.tableFooterView = nil
        }
    }
    
    func addAbilityToDismissKeyboard(tapsRequired taps: Int) {
        if taps == 2 {
            gestureToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(prepareToDismissKeyboard))
            (gestureToDismissKeyboard as! UITapGestureRecognizer).numberOfTapsRequired = 2
            gestureToDismissKeyboard?.cancelsTouchesInView = true
            //singleTapGestureWaitsForDoubleTap = UITapGestureRecognizer(target: self, action: nil)
            //view.addGestureRecognizer(singleTapGestureWaitsForDoubleTap!)
            tableView.allowsSelection = false
        } else {
            gestureToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(prepareToDismissKeyboard))
        }
        view.addGestureRecognizer(gestureToDismissKeyboard!)
    }
    
    func prepareToDismissKeyboard() {
        cellToDismissKeyboard?.dismissKeyboard()
        view.removeGestureRecognizer(gestureToDismissKeyboard!)
        /*
        if singleTapGestureWaitsForDoubleTap != nil {
            view.removeGestureRecognizer(singleTapGestureWaitsForDoubleTap!)
        }*/
        tableView.allowsSelection = true
    }
    
    func userListener() {
        LoadRequests.gRef.child("Users").child((RequestPageViewController.userName?.unique)!).observe(.childChanged, with: { (snapshot) in
            print("userListener called")
            RequestPageViewController.userName?.info[snapshot.key] = snapshot.value as? String
            self.user = RequestPageViewController.userName
            self.updateUI()
        })
    }
    
    func updateUI() {
        data = user?.getViewableData()
        keys = user?.keysToDisplay
        keysForEditing = user?.keysForEditing
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
            }
        } else if key == "Payments" {
            cell = tableView.dequeueReusableCell(withIdentifier: "payments", for: indexPath)
            if let cell = cell as? PaymentsTableViewCell {
                if let payments = data?["Payments"] {
                cell.payments = payments
                }
                cell.controller = self
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
            }
        }
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.tintColor = UIColor.clear
        return cell
    }

}
