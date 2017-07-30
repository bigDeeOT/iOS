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
    var dataIndex: [String]?
    var useGlobalUser = true
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
        dataIndex = user?.keysToDisplay
        dataIndex?.remove(at: (dataIndex?.index(of: "Bio"))!)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataIndex?.count)!
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        let key = dataIndex?[indexPath.row]
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = data?[key!]
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.tintColor = UIColor.clear
        return cell
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
