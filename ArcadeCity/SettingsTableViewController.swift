//
//  SettingsTableViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/29/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class SettingsTableViewController: UITableViewController {
    
    var settings = [["User Directory", "Driver Documentation", "Configure Driver Docs"],["Logout"]]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = nil
        view.backgroundColor = UIColor(red:0.30, green:0.29, blue:0.29, alpha:1.0)
        tableView.reloadData()
        self.tableView.contentInset = UIEdgeInsetsMake(44,0,0,0);
        tableView.tableFooterView = UIView()
        let userClass = RequestPageViewController.userName?.info["Class"]
        if (userClass == "Rider") || (userClass == "Driver") {
            settings[0].remove(at: settings[0].index(of: "Configure Driver Docs")!)
        }
        if (userClass == "Rider") {
            settings[0][settings[0].index(of: "Driver Documentation")!] = "Drive for Might"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return settings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return settings[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if indexPath.section != (settings.count - 1) {
            cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "logout", for: indexPath)
            cell.backgroundColor = UIColor.clear
        }
        cell.textLabel?.text = settings[indexPath.section][indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == (settings.count - 1) {
            logout()
        } else if indexPath.row == settings[0].index(of: "User Directory") {
            performSegue(withIdentifier: "listOfUsers", sender: nil)
        } else if indexPath.row == settings[0].index(of: "Configure Driver Docs") {
            performSegue(withIdentifier: "configureDocumentation", sender: nil)
        }
    }
    
    private func logout() {
        FBSDKLoginManager().logOut()
        do {
            try Auth.auth().signOut()
        } catch { print("error with firebase logout") }
        RequestPageViewController.userName = nil
        LoadRequests.gRef.child("Requests").removeAllObservers()
        LoadRequests.gRef.child("Users/\(RequestPageViewController.userName?.unique ?? "")").removeAllObservers()
        LoadRequests.clear()
        LoadRequests.numberOfRequestsLoaded = 0
        performSegue(withIdentifier: "logout", sender: nil)
    }
    

}
