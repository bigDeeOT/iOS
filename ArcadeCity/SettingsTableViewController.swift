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

class SettingsTableViewController: UITableViewController, NotificationCellDelegate {
    let NormalSections = 0
    let NotificationSection = 1
    var settings = [["User Directory", "My Documents", "Configure Driver Docs", "About", "Privacy Policy"], ["Notifications"], ["Logout"]]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = nil
        view.backgroundColor = UIColor(red:0.30, green:0.29, blue:0.29, alpha:1.0)
        self.tableView.contentInset = UIEdgeInsetsMake(44,0,0,0);
        tableView.tableFooterView = UIView()
        let userClass = RequestPageViewController.userName?.info["Class"]
        if (userClass == "Rider") || (userClass == "Pending Driver") || (userClass == "Driver") {
            settings[0].remove(at: settings[0].index(of: "Configure Driver Docs")!)
        }
        if (userClass == "Rider") {
            settings[0][settings[0].index(of: "My Documents")!] = "Drive for Might"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tableView.reloadData()
    }
    
    func notificationsSetOn(_ on: Bool) {
        let user = RequestPageViewController.userName!
        let value = on ? "True" : "False"
        user.info["Notify"] = value
        LoadRequests.updateUser(user: RequestPageViewController.userName!)
        if on { LoadRequests.setNotificationToken(user.unique!) }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if indexPath.section == NormalSections {
            cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        } else if indexPath.section == NotificationSection {
            cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)
            if let cell = cell as? NotificationTableViewCell {
                let value = RequestPageViewController.userName?.info["Notify"] == "True" ? true : false
                cell.setNotification(value)
                cell.delegate = self
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "logout", for: indexPath)
        }
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.textLabel?.text = settings[indexPath.section][indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let section = indexPath.section
        if section == (settings.count - 1) {
            logout()
        } else if row == settings[section].index(of: "User Directory") {
            performSegue(withIdentifier: "listOfUsers", sender: nil)
        } else if row == settings[section].index(of: "Configure Driver Docs") {
            performSegue(withIdentifier: "configureDocumentation", sender: nil)
        } else if (row == settings[section].index(of: "My Documents")) || (row == settings[0].index(of: "Drive for Might")){
            performSegue(withIdentifier: "DriverDocs", sender: nil)
        } else if (row == settings[section].index(of: "About")) {
            let aboutVC = AboutViewController()
            navigationController?.pushViewController(aboutVC, animated: true)
        } else if (row == settings[section].index(of: "Privacy Policy")) {
            let url = URL(string: "https://drive.google.com/open?id=10sgB54IXbuIXHMCpygt3_JpqsHGKyar1")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
    func logout() {
        let userID = RequestPageViewController.userName?.unique
        LoadRequests.gRef.child("Users").child(userID!).child("LoggedIn").setValue("False")
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
