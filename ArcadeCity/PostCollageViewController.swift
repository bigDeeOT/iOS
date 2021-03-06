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
        guard let rideRequest = rideRequest else { return }
        offer.location = setLocation.latLog
        offer.eta = rideRequest.ETA
        LoadRequests.addOffer(offer, for: rideRequest)
        offer.driver?.info["offerRideComment"] = comment.text
        RequestPageViewController.userName?.incrementVariable("Rides Offered")
        
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
            eta.isHidden = true
        } else {
            let destination = rideRequest?.info["Location"] ?? "Austin"
            setLocation.setETA(to: destination, for: self)
            eta.text = rideRequest?.ETA
        }
        comment.layer.borderWidth = 1
        comment.layer.borderColor = UIColor.lightGray.cgColor
        comment.tintColor = UIColor(red:0.16, green:0.46, blue:0.75, alpha:1.0)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        comment.text = RequestPageViewController.userName!.info["offerRideComment"]
        comment.selectedTextRange = comment.textRange(from: comment.beginningOfDocument, to: comment.endOfDocument)
        comment.becomeFirstResponder()
    }
    
    func etaIsReady(text etaText: String, value etaValue: Int) {
        rideRequest?.ETA = etaText + " away"
        eta.text = rideRequest?.ETA
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
