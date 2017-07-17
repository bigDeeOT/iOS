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
    
    @IBOutlet weak var pickUpText: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var eta: UILabel!
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
                sender.setTitleColor(UIColor.black, for: .normal)
                rideRequest?.resolvedBy = nil
            }
        }
    }
    

    @IBOutlet weak var tableView: UITableView!
    
    func updateUI() {
        loadImage()
        name.text = rideRequest?.rider?.name
        date.text = "2min"
        eta.text = rideRequest?.ETA
        pickUpText.text = rideRequest?.text
        pickUpText.lineBreakMode = .byWordWrapping
        pickUpText.numberOfLines = 0
        tableView.tableFooterView = UIView()
        setOfferButton()
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
            offerRideButton.setTitle("#Resolved by \(rideRequest?.resolvedBy?.name ?? "error")", for: .normal)
            offerRideButton.setTitleColor(UIColor.red, for: .normal)
        }
        //if ride is canceled
        if rideRequest?.state == RideRequest.State.canceled {
            offerRideButton.setTitle("#Canceled", for: .normal)
            offerRideButton.setTitleColor(UIColor.red, for: .normal)
        }
        //if viewer is rider, remove the button until it's resolved
        if (RequestPageViewController.userName?.privilege)! == .rider {
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
        if navigationController?.viewControllers[(navigationController?.viewControllers.count)! - 2] is PostCollageViewController {
            navigationController?.popToViewController((navigationController?.viewControllers[(navigationController?.viewControllers.count)! - 3])!, animated: false)
        }
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 208
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rideRequest = rideRequest  {
            if let offers = rideRequest.offers {
                return offers.count
            }
        }
        return 0
    }
    
    @available(iOS 2.0, *)
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
        /*
        if segue.identifier == "dfdf" {
            if let vc = segue.destination as? UIViewController {
                
            }
        }
 */
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
    

}
