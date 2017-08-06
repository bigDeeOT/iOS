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
    @IBOutlet weak var profilePic: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        loadImage()
    }
    
    private func loadImage() {
        if let url = URL(string: (RequestPageViewController.userName?.info["Profile Pic URL"])!) {
            DispatchQueue.global(qos: .default).async {
                [weak self] in
                if let imageData = NSData(contentsOf: url) {
                    DispatchQueue.main.async {
                        self?.profilePic?.image = UIImage(data: imageData as Data)
                        self?.profilePic?.layer.borderWidth = 3
                        self?.profilePic?.layer.borderColor = UIColor.white.cgColor
                        self?.profilePic?.layer.cornerRadius = (self?.profilePic?.frame.width)! / 2
                        self?.profilePic?.clipsToBounds = true
                        
                    }
                }
            }
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
        if let vc = segue.destination as? MiddleProfileTableViewController {
            vc.user = RequestPageViewController.userName
        } else if let vc = segue.destination as? BottomProfileViewController {
            vc.user = RequestPageViewController.userName
            vc.containingView = self
        } else if let vc = segue.destination as? ImageViewController {
            vc.image = sender as? UIImageView
            vc.hideNavigationBarOnExit = true
        }
    }
  

}
