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

class LoadingPageMain: UIViewController {
    var requestPage: RequestPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestPage?.loadingPage = self
        let loadPic = UIImageView(image: UIImage(named: "loadingPage"))
        loadPic.frame = UIScreen.main.bounds
        loadPic.frame.origin.y = 64
        //loadPic.frame.size.height = loadPic.frame.size.height - 64
        view.bringSubview(toFront: loadPic)
    }
    
}
