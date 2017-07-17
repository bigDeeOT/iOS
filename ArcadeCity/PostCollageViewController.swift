//
//  PostCollageViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/15/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class PostCollageViewController: UIViewController {
    var rideRequest: RideRequest?
    @IBOutlet weak var eta: UILabel!
  
    @IBOutlet weak var comment: UITextView!
    
    @IBAction func submit(_ sender: Any) {
        let offer = Offer(user: RequestPageViewController.userName!, comment: comment.text, date: Date())
        rideRequest?.offers?.append(offer)
        performSegue(withIdentifier: "postCollageSubmit", sender: rideRequest)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if rideRequest?.showETA == false {
            print("removed eta")
            eta.removeFromSuperview()
        } else {
            eta.text = rideRequest?.ETA
            print("riderequest eta is \(rideRequest?.ETA ?? "no ride request eta found")")
        }
        comment.layer.borderWidth = 1
        comment.layer.borderColor = UIColor.lightGray.cgColor
    }

       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? RideDetailViewController
        vc?.rideRequest = sender as? RideRequest
    }
   

}
