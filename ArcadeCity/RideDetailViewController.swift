//
//  RideDetailViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/15/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class RideDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "rideRequestDetail"
    var rideRequest: RideRequest?
    @IBOutlet weak var delete: UIImageView!
    @IBOutlet weak var seperator: UIView!
    @IBOutlet weak var pickUpText: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var eta: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var offerRideButton: UIButton!
    var justClickOfferRide = false
    var loadedImage = false
    @IBAction func offerRide(_ sender: UIButton) {
        if sender.currentTitle == "Offer Ride" {    //post collage
            sender.setTitle("Resolve?", for: .normal)
            performSegue(withIdentifier: "postCollage", sender: rideRequest)
        } else if sender.currentTitle == "Resolve?" {  //resolve the request
            LoadRequests.requestEditedLocally = rideRequest?.unique
            rideRequest?.resolvedBy = RequestPageViewController.userName
            rideRequest?.info["Resolved By"] = RequestPageViewController.userName?.unique
            rideRequest?.info["State"] = "#Resolved"
            sender.setTitle("#Resolved by \(rideRequest?.resolvedBy?.info["Name"] ?? "error")", for: .normal)
            LoadRequests.changeRideRequestStatus(rideRequest!, status: "#Resolved")
            rideRequest?.rider?.incrementVariable("Rides Resolved")
            rideRequest?.resolvedBy?.incrementVariable("Rides Given")
            sender.setTitleColor(UIColor.red, for: .normal)
        } else if (sender.currentTitle?.contains("#Resolved"))! {  //unresolve the request
            LoadRequests.requestEditedLocally = rideRequest?.unique
            if rideRequest?.resolvedBy?.info["Name"] == RequestPageViewController.userName?.info["Name"] {
                sender.setTitle("Resolve?", for: .normal)
                sender.setTitleColor(UIColor(red:0.02, green:0.32, blue:0.54, alpha:1.0), for: .normal)
                rideRequest?.info["State"] = "Unresolved"
                rideRequest?.resolvedBy?.decrementVariable("Rides Given")
                rideRequest?.resolvedBy = nil
                rideRequest?.rider?.decrementVariable("Rides Resolved")
                LoadRequests.changeRideRequestStatus(rideRequest!, status: "Unresolved")
            }
        }
    }
    


    func updateUI() {
        if loadedImage == false {
            loadImage()
            loadedImage = true
        }
        name.text = rideRequest?.rider?.info["Name"]
        date.text = TimeAgo.get((rideRequest?.info["Date"])!)
        pickUpText.text = rideRequest?.info["Text"]
        pickUpText.lineBreakMode = .byWordWrapping
        pickUpText.numberOfLines = 0
        tableView.tableFooterView = UIView()
        etaLogic()
        setOfferButton()
        seperatorLogic()
        configureDeleteButton()
        if justClickOfferRide == true {
            justClickOfferRide = false
            offerRideButton.setTitle("Resolve?", for: .normal)
        }
    }
    
    func reload() {
        tableView.reloadData()
        seperatorLogic()
        date.text = TimeAgo.get(rideRequest?.date ?? Date())
    }
    
    private func etaLogic() {
        if ETA.shouldHideEta(rideRequest!) {
            eta.isHidden = true
        } else {
            rideRequest?.ETA
            eta.isHidden = false
        }
    }
    
    private func seperatorLogic() {
        if rideRequest?.offers?.isEmpty == true {
            seperator.isHidden = true
        } else {
            seperator.isHidden = false
        }
    }
    
    func requestWasDeleted() {
        let deleteLabel = UILabel()
        deleteLabel.text = "DELETED"
        deleteLabel.font = UIFont(name: deleteLabel.font.fontName, size: 60)
        deleteLabel.textColor = UIColor.red
        view.addSubview(deleteLabel)
        deleteLabel.sizeToFit()
        deleteLabel.frame.origin = CGPoint(x: UIScreen.main.bounds.width / 2 - (deleteLabel.frame.width / 2), y: UIScreen.main.bounds.height / 5 - (deleteLabel.frame.height / 2))
        print("about to execute timer")
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            self.performSegue(withIdentifier: "deleteRequest", sender: nil)
        }
    }
    
    private func setOfferButton() {
        offerRideButton.isHidden = false
        //if driver viewing has posted an offer
        if rideRequest?.info["State"] == "Unresolved" {
            for offer in (rideRequest?.offers)! {
                if offer.driver?.info["Name"] == RequestPageViewController.userName?.info["Name"] {
                    offerRideButton.setTitle("Resolve?", for: .normal)
                }
            }
        }
        //if ride is resolved
        if rideRequest?.info["State"] == "#Resolved" {
            offerRideButton.setTitle("#Resolved by \(rideRequest?.resolvedBy?.info["Name"] ?? "Linda")", for: .normal)
            offerRideButton.setTitleColor(UIColor.red, for: .normal)
        }
        //if ride is canceled
        if rideRequest?.info["State"] == "#Canceled" {
            offerRideButton.setTitle("#Canceled", for: .normal)
            offerRideButton.setTitleColor(UIColor.red, for: .normal)
        }
        //if viewer only has rider privilege, or if viwer is original requester of ride, remove the button until it's resolved
        if ((RequestPageViewController.userName?.info["Class"])! == "Rider") || ((RequestPageViewController.userName?.info["Name"])! == rideRequest?.rider?.info["Name"]) {
            if (rideRequest?.info["State"] != "#Resolved") && (rideRequest?.info["State"] != "#Canceled") {
                //offerRideButton.removeFromSuperview()
                offerRideButton.isHidden = true
            }
        }
        //if ride is old, don't allow offer ride
        if (rideRequest?.isOld)! && (rideRequest?.info["State"] == "Unresolved") {
            offerRideButton.isHidden = true
        }
        if RequestPageViewController.userName?.info["Collage URL"] == nil {
            offerRideButton.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        tableView.delegate = self
        tableView.dataSource = self
        updateUI()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 208
        rideRequest?.delegate = self
        LoadRequests.rideDetailPage = self
    }
    
    func configureDeleteButton() {
        delete.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteOptions)))
        delete.isUserInteractionEnabled = true
        delete.frame.size = ImageResize.getNewSize(currentSize: delete.frame.size, maxSize: CGSize(width: 20, height: 20))
        if rideRequest?.rider?.info["Name"] != RequestPageViewController.userName?.info["Name"] {
            delete.isHidden = true
        } else {
            delete.isHidden = false
        }
        /*
        if rideRequest?.info["State"] == "#Resolved" {
            delete.isHidden = true
        } else {
            delete.isHidden = faulse
        }
         
 */
        
    }
    
    func deleteOptions() {
        let actionSheet = UIAlertController(title: "Delete the request?", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.deleteRequest()
        }
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(deleteAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    func deleteRequest() {
        LoadRequests.removeRideRequest(rideRequest!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        tableView.reloadData()
        seperatorLogic()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rideRequest = rideRequest  {
            if let offers = rideRequest.offers {
                return offers.count
            }
        }
        return 0
    }
    
    //@available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RideDetailTableViewCell
            cell.offer = rideRequest?.offers?[indexPath.row]
        cell.controller = self
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postCollage" {
            if let vc = segue.destination as? PostCollageViewController {
                vc.rideRequest = (sender as? RideRequest)
            }
        }
        if let vc = segue.destination as? ImageViewController {
            vc.image = sender as? UIImageView
            print("preparing segue")
        }
        if let vc = segue.destination as? RequestPageViewController {
            print("ride detail, prepare for segue")
            vc.rideRequestList.reloadData()
        }
    }
    
    private func loadImage() {
        if let url = URL(string: (rideRequest?.rider?.info["Profile Pic URL"])!) {
            DispatchQueue.global(qos: .default).async {
                [weak self] in
                if let imageData = NSData(contentsOf: url) {
                    DispatchQueue.main.async {
                        self?.profilePic?.image = UIImage(data: imageData as Data)
                        self?.profilePic.layer.borderWidth = 1
                        self?.profilePic.layer.borderColor = UIColor.lightGray.cgColor

                    }
                }
            }
        }
    }
    
    @IBAction func unwindToRideDetail(segue: UIStoryboardSegue) {
    seperatorLogic()
    }

}
