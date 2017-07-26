//
//  ProfileViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/25/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var collageView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collageView.isHidden = false
        if RequestPageViewController.userName?.keyValues["Class"] == "Rider" {
            collageView.isHidden = true
            fixMiddleViewHeight()
        }
        
    }
    
    func fixMiddleViewHeight() {
        let widthOfMiddle = middleView.frame.size.width
        let heightOfMiddle = middleView.frame.size.height
        let topOfMiddle = middleView.frame.origin.y
        let topOfTabBar = (tabBarController?.tabBar.frame.origin.y)!
        let middleHeightToAdd = topOfTabBar - (topOfMiddle + heightOfMiddle)
        middleView.frame.size = CGSize(width: widthOfMiddle, height: heightOfMiddle + middleHeightToAdd)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TopProfileViewController {
            print("segue to top")
            vc.user = RequestPageViewController.userName
        } else if let vc = segue.destination as? MiddleProfileTableViewController {
            print("segue to middle")
            vc.user = RequestPageViewController.userName
        } else if let vc = segue.destination as? BottomProfileViewController {
            print("segue to bottom")
            vc.user = RequestPageViewController.userName
        }
    }
  

}
