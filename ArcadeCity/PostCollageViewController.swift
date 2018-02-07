//
//  PostCollageViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/15/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class PostCollageViewController: UIViewController, ETADelegate {
    
    var rideRequest: RideRequest?
    let setLocation = SetLocation()
    @IBOutlet weak var eta: UILabel!
  
    @IBOutlet weak var comment: UITextView!
    
    @IBAction func submit(_ sender: Any) {
        let offer = Offer(user: RequestPageViewController.userName!, comment: comment.text, date: Date())
        if let rideRequest = rideRequest {
            //need to get updated rideRequest state here
            if rideRequest.info["State"] == "Unresolved" {
                offer.location = setLocation.latLog
                offer.eta = rideRequest.ETA
                LoadRequests.addOffer(offer, for: rideRequest)
                RequestPageViewController.userName?.incrementVariable("Rides Offered")
            }
            
        }
        
        //we don't want user to go "back" to this page
      
        //if coming from the rideDetail vc
        for nvc in (navigationController?.viewControllers)! {
            if nvc is RideDetailViewController {
                performSegue(withIdentifier: "unwindToRideDetail", sender: rideRequest)
                return
            }
        }
        //if coming from requestPage vc
        performSegue(withIdentifier: "unwindToRequestPage", sender: rideRequest)
        
 
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if rideRequest?.info["Show ETA"] == "False" {
            print("removed eta")
            eta.isHidden = true
        } else {
            let destination = rideRequest?.info["Location"] ?? "Austin"
            setLocation.setETA(to: destination, for: self)
            /*
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (time) in
                self.eta.text = self.rideRequest?.ETA
            })
 */
            eta.text = rideRequest?.ETA
            print("riderequest eta is \(rideRequest?.ETA ?? "no ride request eta found")")
        }
        comment.layer.borderWidth = 1
        comment.layer.borderColor = UIColor.lightGray.cgColor
        comment.tintColor = UIColor(red:0.16, green:0.46, blue:0.75, alpha:1.0)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func etaIsReady(_ eta: String) {
        rideRequest?.ETA = eta + " away"
        self.eta.text = rideRequest?.ETA
    }

    func dismissKeyboard() {
        comment.endEditing(true)
    }
    
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RideDetailViewController {
            vc.rideRequest = sender as? RideRequest
        } else if let vc = segue.destination as? RequestPageViewController {
            vc.pendingRequest = sender as? RideRequest
        }
        
    }
   

}
