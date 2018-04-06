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
    var spinner: UIActivityIndicatorView?
    @IBOutlet weak var login: UIButton!
    var locationBarrier: Bool?
    var userIsLocal: Bool? {
        didSet { loginLogic() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButton()
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        view.addSubview(spinner!)
        spinner?.center = view.center
        login.isHidden = true
    }
    
    private func loginLogic() {
        let inRange = userIsLocal == true || locationBarrier == false
        if proceedWithAutomaticSignIn && inRange {
            finishedLogin()
            loadRequests.checkIfUserExists()
        } else if inRange {
            login.isHidden = false
        } else {
            onlyInAustin()
        }
        spinner?.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        login.isHidden = true
        spinner?.startAnimating()
        setLocationBarrier()
        location.setETA(to: "Austin", for: self)
        if Auth.auth().currentUser?.uid != nil && FBSDKAccessToken.current()?.tokenString != nil {
            proceedWithAutomaticSignIn = true
        }
    }
    
    private func setLocationBarrier() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let date = dateFormatter.date(from: "04-20-2018")
        if Date().timeIntervalSince(date!) > 0 {
            self.locationBarrier = true
        } else {
            self.locationBarrier = false
        }
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
        loadRequests.login(fromViewController: self)
        loadRequests.loginPageDelegate = self
    }
    
    func finishedLogin() {
        spinner?.stopAnimating()
        performSegue(withIdentifier: loginSegueIdentifier, sender: nil)
    }
    
    private func onlyInAustin() {
        let label = UILabel()
        label.text = "Might is only available in Austin, TX"
        label.sizeToFit()
        label.center = self.view.center
        self.view.addSubview(label)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let tabBarVc = segue.destination as? UITabBarController else {return}
        guard let navigationVc = tabBarVc.viewControllers?[0] as? UINavigationController else {return}
        guard let requestPage = navigationVc.viewControllers[0] as? RequestPageViewController else {return}
        requestPage.loadRequests = loadRequests
    }
    
}




