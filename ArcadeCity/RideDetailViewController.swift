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
    
    @IBOutlet weak var seperator: UIView!
    @IBOutlet weak var pickUpText: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var eta: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var offerRideButton: UIButton!
    @IBAction func offerRide(_ sender: UIButton) {
        if sender.currentTitle == "Offer Ride" {    //post collage
            sender.setTitle("Resolve?", for: .normal)
            performSegue(withIdentifier: "postCollage", sender: rideRequest)
        } else if sender.currentTitle == "Resolve?" {  //resolve the request
            print("changing to resolved")
            rideRequest?.resolvedBy = RequestPageViewController.userName
            sender.setTitle("#Resolved by \(rideRequest?.resolvedBy?.name ?? "error")", for: .normal)
            sender.setTitleColor(UIColor.red, for: .normal)
            rideRequest?.resolvedBy = RequestPageViewController.userName
        } else if (sender.currentTitle?.contains("#Resolved"))! {  //unresolve the request
            if rideRequest?.resolvedBy?.name == RequestPageViewController.userName?.name {
                sender.setTitle("Resolve?", for: .normal)
                sender.setTitleColor(UIColor(red:0.02, green:0.32, blue:0.54, alpha:1.0), for: .normal)
                rideRequest?.resolvedBy = nil
                rideRequest?.state = RideRequest.State.unresolved
            }
        }
    }
        
    func updateUI() {
        loadImage()
        name.text = rideRequest?.rider?.name
        date.text = TimeAgo.get(rideRequest?.date ?? Date())
        pickUpText.text = rideRequest?.text
        pickUpText.lineBreakMode = .byWordWrapping
        pickUpText.numberOfLines = 0
        tableView.tableFooterView = UIView()
        etaLogic()
        setOfferButton()
        seperatorLogic()
    }
    
    private func etaLogic() {
        if (rideRequest?.isOld)! || (RequestPageViewController.userName?.name == rideRequest?.rider?.name) {
            eta.isHidden = true
        } else {
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
    
    private func setOfferButton() {
        //if driver viewing has posted an offer
        if rideRequest?.state == RideRequest.State.unresolved {
            for offer in (rideRequest?.offers)! {
                if offer.driver?.name == RequestPageViewController.userName?.name {
                    offerRideButton.setTitle("Resolve?", for: .normal)
                }
            }
        }
        //if ride is resolved
        if rideRequest?.state == RideRequest.State.resolved {
            offerRideButton.setTitle("#Resolved by \(rideRequest?.resolvedBy?.name ?? "Linda")", for: .normal)
            offerRideButton.setTitleColor(UIColor.red, for: .normal)
        }
        //if ride is canceled
        if rideRequest?.state == RideRequest.State.canceled {
            offerRideButton.setTitle("#Canceled", for: .normal)
            offerRideButton.setTitleColor(UIColor.red, for: .normal)
        }
        //if viewer only has rider privilege, or if viwer is original requester of ride, remove the button until it's resolved
        if ((RequestPageViewController.userName?.privilege)! == .rider) || ((RequestPageViewController.userName?.name)! == rideRequest?.rider?.name) {
            if (rideRequest?.state != RideRequest.State.resolved) && (rideRequest?.state != RideRequest.State.canceled) {
                offerRideButton.removeFromSuperview()
            }
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "postCollage" {
            if let vc = segue.destination as? PostCollageViewController {
                vc.rideRequest = (sender as? RideRequest)
            }
        }
    }
    
    private func loadImage() {
        if let url = rideRequest?.rider?.profilePicURL {
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
