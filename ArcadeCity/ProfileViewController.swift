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

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        loadImage()
        if profileIsForEditing == false { setBackButton() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setBackButton() {
        let backButton = UILabel()
        backButton.textColor = UIColor.white
        view.addSubview(backButton)
        backButton.frame.origin.x = 20
        let arrow = NSMutableAttributedString(string: " <   \n     ", attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 25)])
        backButton.attributedText = arrow
        backButton.sizeToFit()
        //backButton.frame.origin.y = middleView.frame.origin.y - (backButton.frame.size.height / 2) - 2
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
