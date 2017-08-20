//
//  SetUserClassViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/16/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class SetUserClassViewController: UIViewController {
    var user: User!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var options: UISegmentedControl!
    @IBOutlet weak var topTitle: UILabel!
    var classTypes = ["Rider" : 0, "Driver" : 1, "Moderator" : 2, "Admin" : 3, "Banned" : 4]
    override func viewDidLoad() {
        super.viewDidLoad()
        options.selectedSegmentIndex = classTypes[user.info["Class"]!]!
        if RequestPageViewController.userName?.info["Class"] != "Admin" {
            options.removeSegment(at: 4, animated: false)
            options.removeSegment(at: 3, animated: false)
            options.removeSegment(at: 2, animated: false)
            options.insertSegment(withTitle: "Banned", at: 2, animated: false)
            if user.info["Class"] == "Banned" {
                options.selectedSegmentIndex = 2
            }
        }
        topTitle.text = topTitle.text?.replacingOccurrences(of: "User", with: user.info["Name"]!)
        topTitle.lineBreakMode = .byWordWrapping
        topTitle.numberOfLines = 0
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        LoadRequests.gRef.child("\(user.info["Class"] ?? "")s/\(user.unique ?? "")").removeValue()
        var userClass = options.titleForSegment(at: options.selectedSegmentIndex)
        if userClass == "Mod" {userClass = "Moderator"}
        user.info["Class"] = userClass
        LoadRequests.updateUser(user: user)
        if user.unique == RequestPageViewController.userName?.unique {
            RequestPageViewController.userName = user
        }
        performSegue(withIdentifier: "unwindToListOfUsers", sender: nil)
    }
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ListOfUsersViewController {
            vc.tableViewUsers.reloadData()
        }
    }
    

}
