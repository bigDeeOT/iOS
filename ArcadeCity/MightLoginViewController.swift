//
//  MightLoginViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/6/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

protocol loginDelegate {
    func finishedLogin()
}

class MightLoginViewController: UIViewController, loginDelegate {
    let loginSegueIdentifier = "goToRequestPage"
    var loadRequests = LoadRequests()
    
    @IBOutlet weak var login: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButton()
        print("might login viewDidLoad")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let firebaseID = Auth.auth().currentUser?.uid else {return}
        guard let facebookID = FBSDKAccessToken.current()?.tokenString else {return}
        //User is already signed in
        print(firebaseID,facebookID)
        finishedLogin()
        loadRequests.checkIfUserExists()
    }

    func configureButton() {
        login.layer.borderWidth = 3
        login.layer.borderColor = UIColor.white.cgColor
        login.layer.cornerRadius = 15
    }
    
    @IBAction func login(_ sender: UIButton) {
        loadRequests.login(fromViewController: self)
        loadRequests.loginPageDelegate = self
    }
    
    func finishedLogin() {
        performSegue(withIdentifier: loginSegueIdentifier, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let tabBarVc = segue.destination as? UITabBarController else {return}
        guard let navigationVc = tabBarVc.viewControllers?[0] as? UINavigationController else {return}
        guard let requestPage = navigationVc.viewControllers[0] as? RequestPageViewController else {return}
        requestPage.loadRequests = loadRequests
        loadRequests.requestPage = requestPage //?? need this?
    }
    
}









