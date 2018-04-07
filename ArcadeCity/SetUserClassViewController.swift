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
    var optionsForMods: UISegmentedControl!
    @IBOutlet weak var topTitle: UILabel!
    var classTypesForAdmin = ["Rider" : 0, "Driver" : 1, "Moderator" : 2, "Admin" : 3, "Banned" : 4, "Pending Driver" : 5]
    var classTypesForMod = ["Rider" : 0, "Driver" : 1, "Pending Driver" : 2]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        options.selectedSegmentIndex = classTypesForAdmin[user.info["Class"]!]!
        setupOptionsForMods()
        topTitle.text = topTitle.text?.replacingOccurrences(of: "User", with: user.info["Name"]!)
        topTitle.lineBreakMode = .byWordWrapping
        topTitle.numberOfLines = 0
    }
    
    private func setupOptionsForMods() {
        guard RequestPageViewController.userName?.info["Class"] == "Moderator" else { return }
        optionsForMods = UISegmentedControl()
        optionsForMods.insertSegment(withTitle: "Rider", at: 0, animated: false)
        optionsForMods.insertSegment(withTitle: "Driver", at: 1, animated: false)
        optionsForMods.insertSegment(withTitle: "Pending Driver", at: 2, animated: false)
        optionsForMods.frame = options.frame
        view.addSubview(optionsForMods)
        options.removeFromSuperview()
        optionsForMods.selectedSegmentIndex = classTypesForMod[user.info["Class"]!]!
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        var userClass: String!
        LoadRequests.gRef.child("\(user.info["Class"] ?? "")s/\(user.unique ?? "")").removeValue()
        if RequestPageViewController.userName?.info["Class"] == "Admin" {
            userClass = options.titleForSegment(at: options.selectedSegmentIndex)
        } else {
            userClass = optionsForMods.titleForSegment(at: optionsForMods.selectedSegmentIndex)
        }
        if userClass == "Mod" {userClass = "Moderator"}
        if userClass == "Pending" {userClass = "Pending Driver"}
        user.info["Class"] = userClass
        LoadRequests.updateUser(user: user)
        if user.unique == RequestPageViewController.userName?.unique {
            RequestPageViewController.userName?.info = user.info
        }
        performSegue(withIdentifier: "unwindToListOfUsers", sender: nil)
    }
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ListOfUsersViewController {
            vc.tableViewUsers.reloadData()
        }
    }
    

}
