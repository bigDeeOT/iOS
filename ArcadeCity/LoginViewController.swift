//
//  LoginViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/24/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class LoginViewController: UIViewController {
    var loadRequests = LoadRequests()
    var waiting = false
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var requestPage: RequestPageViewController?
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        requestPage?.login()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if waiting == false {
            spinner.stopAnimating()
        }
        loginButton.layer.borderWidth = 3
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.cornerRadius = 10
        loginButton.backgroundColor = UIColor(red:0.42, green:0.72, blue:0.94, alpha:0.2)
        requestPage?.loginPage = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        print(Auth.auth().currentUser?.uid ?? "not logged in")
        if Auth.auth().currentUser?.uid != nil {
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
