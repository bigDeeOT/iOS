//
//  WaitingForDatabaseViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/21/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class WaitingForDatabaseViewController: UIViewController {
    
    func go() {
            performSegue(withIdentifier: "ready", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
