//
//  SettingsTableViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/29/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    var settings = [["Notifications","Moderators","Templates",],["Logout"]]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = nil
        view.backgroundColor = UIColor(red:0.30, green:0.29, blue:0.29, alpha:1.0)
        tableView.reloadData()
        self.tableView.contentInset = UIEdgeInsetsMake(44,0,0,0);
        tableView.tableFooterView = UIView()
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
            print("logout")
            RequestPageViewController.this?.logout()

        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
