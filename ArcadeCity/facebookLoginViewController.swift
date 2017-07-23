//
//  facebookLoginViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/19/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase


class facebookLoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonMethod(_ sender: Any) {
        label.text = FBSDKAccessToken.current()?.tokenString ?? "None"
    }
    @IBOutlet weak var label: UILabel!
    var customFBbutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = FBSDKLoginButton()
        loginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        view.addSubview(loginButton)
        
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        
        //custom button
        
        customFBbutton = UIButton(type: .system)
        customFBbutton.backgroundColor = .blue
        customFBbutton.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
        customFBbutton.setTitle("Login", for: .normal)
        customFBbutton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customFBbutton.setTitleColor(.white, for: .normal)
        view.addSubview(customFBbutton)
        
        customFBbutton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        
    }
    func handleCustomFBLogin() {
        print("user ID is ",Auth.auth().currentUser?.uid ?? "no id found")
        if (customFBbutton?.currentTitle! == "Login") {
            FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, err) in
                if err != nil {
                    print("Custom FB login failed", err ?? "")
                    return
                }
                print("we are INSIDE the login manager checking if there is a token\n")
                //print(FBSDKAccessToken.current()?.tokenString ?? "No there isn't")
                self.fbInfo()
            }
            FBSDKProfile.enableUpdates(onAccessTokenChange: true)
            self.fbInfo()
            customFBbutton?.setTitle("Logout", for: .normal)
        } else {
            print("logging out, access token is: ", FBSDKAccessToken.current()?.tokenString ?? "None")
            customFBbutton?.setTitle("Login", for: .normal)
            FBSDKLoginManager().logOut()
            do {
                try Auth.auth().signOut()
            } catch { print("error with firebase logout")}
            print("We logged out")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        fbInfo()
    }
    
    func fbInfo() {
        guard let accessToken = FBSDKAccessToken.current() else {
            print("accessToken is nil")
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
        Auth.auth().signIn(with: credential) { (user, err) in
            if err != nil {
                print("\ncould not authenticate firebase fb signin",err ?? "")
                return
            }
            print("\n\nsuccessfully logged in with user\n", user ?? "")
            print("user ID is ",Auth.auth().currentUser?.uid ?? "")
        }
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            if err != nil {
                print("failed to print out graph request", err ?? "")
                return
            }
            print(result ?? "")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    

}
