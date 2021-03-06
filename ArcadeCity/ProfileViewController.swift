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
    var user: User?
    var profileIsForEditing = true
    var navBarColor = UIColor(red:0.16, green:0.46, blue:0.75, alpha:1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        navigationBarStyle()
        loadImage()
        if profileIsForEditing == false { setBackButton() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func navigationBarStyle() {
        let navBar = navigationController?.navigationBar
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        navBar?.barTintColor = navBarColor
        navBar?.tintColor = UIColor.white
        navBar?.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold)
        ]
        navBar?.setValue(true, forKey: "hidesShadow")
        navBar?.isTranslucent = false
    }
    
    private func setBackButton() {
        let backButton = UILabel()
        backButton.textColor = UIColor.white
        view.addSubview(backButton)
        backButton.frame.origin.x = 20
        let arrow = NSMutableAttributedString(string: " <   \n     ", attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 25)])
        backButton.attributedText = arrow
        backButton.sizeToFit()
        backButton.frame.origin.y = 55
        backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goBack)))
        backButton.isUserInteractionEnabled = true
    }
    
    func goBack() {
        navigationController?.popViewController(animated: true)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func typeOfProfile() {
        if user == nil {
            user = RequestPageViewController.userName
        } else {
            profileIsForEditing = false
        }
    }
    
    private func loadImage() {
        profilePic?.frame.origin.x = view.frame.size.width / 2 - profilePic!.frame.size.width / 2
        if let url = URL(string: (user?.info["Profile Pic URL"])!) {
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MiddleProfileTableViewController {
            typeOfProfile()
            vc.profileIsForEditing = profileIsForEditing
            vc.profileDelegate = self
            vc.user = user
        } else if let vc = segue.destination as? ImageViewController {
            vc.image = sender as? UIImageView
            vc.hideNavigationBarOnExit = true
        } else if let vc = segue.destination as? MessagingViewController {
            if let user = sender as? User {
                vc.otherUser = user
            }
        }
    }
    
    

}
