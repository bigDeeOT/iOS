//
//  AddRideTableViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/14/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class AddRideTableViewController: UITableViewController {

    
    var identifier = "requestRide"

    @IBOutlet weak var pickUp: UITextField!
    
    @IBOutlet weak var dropOff: UITextField!
    
    @IBOutlet weak var nowOrLater: UISegmentedControl!
    
    @IBOutlet weak var currentLocation: UISegmentedControl!
    
    @IBOutlet weak var otherInfo: UITextView!
        
    @IBAction func requestRide(_ sender: UIButton) {
        let ride = RideRequest()
        if let pickUpText = pickUp.text{
            if pickUpText.characters.count <= 1 {
                //invalid pickup
                return
            }
            ride.text = "\(pickUpText)"
        } else {
            //invalid pickup
            return
        }
        if let dropOffText = dropOff.text{
            if dropOffText.characters.count >= 2 {
                ride.text = ride.text! + " to \(dropOffText)"
            }
        }
        if let otherInfoText = otherInfo.text {
            if otherInfoText.characters.count >= 3 {
                ride.text = ride.text! + "\n" + otherInfoText
            }
        }
        ride.date = Date.init()
        performSegue(withIdentifier: identifier, sender: ride)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        otherInfo.layer.borderWidth = 1
        otherInfo.layer.borderColor = UIColor.lightGray.cgColor
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        otherInfo.endEditing(true)
    }
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == identifier {
            if let ride = sender as? RideRequest {
                LoadRequests.add(request: ride)
            }
        }
    }


}
