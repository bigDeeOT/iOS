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

class MightLoginViewController: UIViewController, loginDelegate, ETADelegate {
    let loginSegueIdentifier = "goToRequestPage"
    var loadRequests = LoadRequests()
    let location = SetLocation()
    var proceedWithAutomaticSignIn = false
    var userIsLocal: Bool? {
        didSet {
            if proceedWithAutomaticSignIn == true && userIsLocal == true {
                finishedLogin()
                loadRequests.checkIfUserExists()
            }
        }
    }
    
    @IBOutlet weak var login: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButton()
        print("might login viewDidLoad")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        location.setETA(to: "Austin", for: self)
        guard let _ = Auth.auth().currentUser?.uid else {return}
        guard let _ = FBSDKAccessToken.current()?.tokenString else {return}
        if userIsLocal == true {
            finishedLogin()
            loadRequests.checkIfUserExists()
        }
        proceedWithAutomaticSignIn = true;
    }
    
    func etaIsReady(text etaText: String, value etaValue: Int) {
        guard userIsLocal == nil else {return}
        if (etaValue > 5400) {
            userIsLocal = false
        } else {
            userIsLocal = true
        }
    }
    
    func configureButton() {
        login.layer.borderWidth = 3
        login.layer.borderColor = UIColor.white.cgColor
        login.layer.cornerRadius = 15
    }
    
    
    @IBAction func login(_ sender: UIButton) {
        guard userIsLocal == true else {
            print("The user is not within the specified area.")
            return
        }
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
        //loadRequests.requestPage = requestPage //?? need this?
    }
    
}




