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
    @IBOutlet weak var currentLocation: UISegmentedControl!
    @IBOutlet weak var otherInfo: UITextView!
    var setLocation = SetLocation()
    var location: String!
    var pickUpGoogleButton: UIButton?
    var dropOffGoogleButton: UIButton?
    var selectedPickUpButton = true
    
    @IBAction func requestRide(_ sender: UIButton) {
        let ride = RideRequest()
        if let pickUpText = pickUp.text{
            if pickUpText.count <= 1 {
                //invalid pickup
                return
            }
            ride.info["Text"] = pickUpText
        } else {
            //invalid pickup
            return
        }
        if let dropOffText = dropOff.text{
            if dropOffText.count >= 2 {
                ride.info["Text"] = ride.info["Text"]! + " to \(dropOffText)"
            }
        }
        if let otherInfoText = otherInfo.text {
            if otherInfoText.count >= 3 {
                ride.info["Text"] = ride.info["Text"]! + "\n" + otherInfoText
            }
        }
        ride.info["Text"] = ride.info["Text"]?.replacingOccurrences(of: " And ", with: " & ")
        ride.info["Text"] = ride.info["Text"]?.replacingOccurrences(of: " A ", with: " a ")
        ride.date = Date.init()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
        let date = dateFormatter.string(from: Date())
        ride.info["Date"] = date
        ride.info["Rider"] = RequestPageViewController.userName?.unique
        ride.info["State"] = "Unresolved"
        ride.info["Show ETA"] = "True"
        if currentLocation.selectedSegmentIndex == 1 {
            ride.info["Show ETA"] = "False"
        }
        ride.rider?.incrementVariable("Rides Requested")
        ride.info["Location"] = setLocation.latLog ?? "n/a"
        performSegue(withIdentifier: identifier, sender: ride)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocation.set()
        tableView.tableFooterView = UIView()
        otherInfo.layer.borderWidth = 1
        otherInfo.layer.borderColor = UIColor.lightGray.cgColor
        otherInfo.layer.cornerRadius = 5
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        dropOff.tintColor = UIColor(red:0.16, green:0.46, blue:0.75, alpha:1.0)
        pickUp.tintColor = UIColor(red:0.16, green:0.46, blue:0.75, alpha:1.0)
        otherInfo.tintColor = UIColor(red:0.16, green:0.46, blue:0.75, alpha:1.0)
        pickUp.becomeFirstResponder()
        pickUp.addTarget(dropOff, action: #selector(becomeFirstResponder), for: UIControlEvents.editingDidEndOnExit)
        dropOff.addTarget(otherInfo, action: #selector(becomeFirstResponder), for: UIControlEvents.editingDidEndOnExit)
        addAutoCompleteButtons()
    }
    
    private func addAutoCompleteButtons() {
        pickUpGoogleButton = UIButton(type: .custom)
        pickUpGoogleButton?.setImage(UIImage(named: "autoComplete"), for: .normal)
        pickUpGoogleButton?.addTarget(self, action: #selector(autoCompleteButton(_:)), for: .touchUpInside)
        pickUpGoogleButton?.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        pickUp.leftView = pickUpGoogleButton
        pickUp.leftViewMode = .whileEditing
        dropOffGoogleButton = UIButton(type: .custom)
        dropOffGoogleButton?.setImage(UIImage(named: "autoComplete"), for: .normal)
        dropOffGoogleButton?.addTarget(self, action: #selector(autoCompleteButton(_:)), for: .touchUpInside)
        dropOffGoogleButton?.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        dropOff.leftView = dropOffGoogleButton
        dropOff.leftViewMode = .whileEditing
    }
    
    func autoCompleteButton(_ sender:UIButton) {
        let autoCompleteVC = AutoCompleteViewController()
        if sender == pickUpGoogleButton {
            selectedPickUpButton = true
            autoCompleteVC.searchPretext = pickUp.text
        } else  {
            selectedPickUpButton = false
            autoCompleteVC.searchPretext = dropOff.text
        }
        autoCompleteVC.addRideVC = self
        let navVC = UINavigationController(rootViewController: autoCompleteVC)
        present(navVC, animated: true, completion: nil)
    }
    
    func autoCompleteClicked(_ name: String) {
        if selectedPickUpButton {
            pickUp.text = name
            dropOff.becomeFirstResponder()
        } else {
            dropOff.text = name
            otherInfo.becomeFirstResponder()
        }
    }
    
    func autoCompleteCanceled() {
        dismiss(animated: true, completion: nil)
        if selectedPickUpButton {
            pickUp.becomeFirstResponder()
        } else {
            dropOff.becomeFirstResponder()
        }
    }
    
    func dismissKeyboard() {
        otherInfo.endEditing(true)
        pickUp.endEditing(true)
        dropOff.endEditing(true)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == identifier {
            if let ride = sender as? RideRequest {
                LoadRequests.add(request: ride)
            }
        }
    }

}
