//
//  ListOfUsersViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/15/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class ListOfUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var navBarColor = UIColor(red:0.16, green:0.46, blue:0.75, alpha:1.0)
    @IBOutlet weak var userGroup: UISegmentedControl!
    var options = ["Users","Drivers","Moderators","Admins","Banneds"]
    @IBOutlet weak var tableViewUsers: UITableView!
    var backend = ListOfUsersBackend()
    var profilePicsCache: [[String:UIImage]] = [[:],[:],[:],[:],[:]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backend.controller = self
        tableViewUsers.delegate = self
        tableViewUsers.dataSource = self
        let userClass = RequestPageViewController.userName?.info["Class"]
        if (userClass == "Rider") || (userClass == "Driver") {
            userGroup.removeSegment(at: 4, animated: false)
        }
    }
    
    @IBAction func userGroupAction(_ sender: UISegmentedControl) {
        clear()
        backend.group = options[sender.selectedSegmentIndex]
        backend.loadList()
    }
    
    private func clear() {
        //profilePicsCache.removeAll()
        backend.users.removeAll()
        backend.pageBoundary = ""
        backend.loadedAllUsers = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = navBarColor
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold)
        ]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return backend.users.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user")
        if let cell = cell as? ListOfUsersTableViewCell {
            cell.user = backend.users[indexPath.row]
            cell.controller = self
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == backend.users.count - 1 {
            guard backend.loadedAllUsers == false else {return}
            backend.loadMore()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProfileViewController {
            vc.user = sender as? User
        }
        if let vc = segue.destination as? SetUserClassViewController {
            vc.user = sender as? User
        }
    }
    
    @IBAction func unwindToListOfUser(segue: UIStoryboardSegue) {
        
    }
    
}
