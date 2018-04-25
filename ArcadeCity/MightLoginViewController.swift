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
    func loginCanceled()
}

class MightLoginViewController: UIViewController, loginDelegate, ETADelegate {
    let loginSegueIdentifier = "goToRequestPage"
    var loadRequests = LoadRequests()
    let location = SetLocation()
    var proceedWithAutomaticSignIn = false
    var spinner: UIActivityIndicatorView?
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var mightLogo: UILabel!
    var locationBarrier: Bool?
    var loginWasCanceled = false
    var userIsLocal: Bool? {
        didSet { loginLogic() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButton()
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        view.addSubview(spinner!)
        spinner?.center = view.center
        spinner?.frame.origin.y += 100
        login.isHidden = true
        addBackground()
    }
    
    private func addBackground() {
        let bg = UIImageView(image: UIImage(named: "loginBG"))
        bg.frame = UIScreen.main.bounds
        view.addSubview(bg)
        view.sendSubview(toBack: bg)
        bg.alpha = 0.5
        view.backgroundColor = UIColor.black
    }
    
    private func loginLogic() {
        let inRange = userIsLocal == true || locationBarrier == false
        if proceedWithAutomaticSignIn && inRange {
            finishedLogin()
            loadRequests.checkIfUserExists()
        } else if inRange {
            showLoginButton()
        } else {
            onlyInAustin()
        }
        spinner?.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard loginWasCanceled == false else {return}
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
        let loginCenter = login.center
        login.frame.size.width = 30
        login.center = loginCenter
        login.setTitleColor(UIColor.clear, for: .normal)
        login.layer.borderWidth = 3
        login.layer.borderColor = UIColor.white.cgColor
        login.layer.cornerRadius = 15
    }
    
    func showLoginButton() {
        login.isHidden = false
        let loginCenter = login.center
        UIView.animate(withDuration: 0.7, animations: {
            self.login.frame.size.width = 230
            self.login.center = loginCenter
        }) { (bool) in
            UIView.transition(with: self.login, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.login.setTitleColor(UIColor.white, for: .normal)
            }, completion: nil)
        }
    }

    
    @IBAction func login(_ sender: UIButton) {
        loginWasCanceled = false
        loadRequests.loginPageDelegate = self
        loadRequests.login(fromViewController: self)
    }
    
    func finishedLogin() {
        spinner?.stopAnimating()
        UIView.animate(withDuration: 0.3, animations: {
            self.mightLogo.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }) { (bool) in
            UIView.animate(withDuration: 0.2, animations: {
                self.mightLogo.alpha = 0
                self.mightLogo.transform = CGAffineTransform(scaleX: 20, y: 20)
            }) { (bool) in
                self.performSegue(withIdentifier: self.loginSegueIdentifier, sender: nil)
            }
        }
    }
    
    func loginCanceled() {
        loginWasCanceled = true
    }
    
    private func onlyInAustin() {
        let label = UILabel()
        label.text = "Might is only available in Austin, TX"
        label.sizeToFit()
        label.center = self.view.center
        label.frame.origin.y += 100
        self.view.addSubview(label)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let tabBarVc = segue.destination as? UITabBarController else {return}
        guard let navigationVc = tabBarVc.viewControllers?[0] as? UINavigationController else {return}
        guard let requestPage = navigationVc.viewControllers[0] as? RequestPageViewController else {return}
        requestPage.loadRequests = loadRequests
    }
    
}




