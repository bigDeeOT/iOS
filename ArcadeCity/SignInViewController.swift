//
//  SignInViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/14/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var textBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RequestPageViewController {
            let rider = Rider(url: URL(string: "http://img.wennermedia.com/article-leads-horizontal/rs-18960-apes-1800-1404228817.jpg")!, name: textBox.text!)
            vc.userName = rider
        }
    }
    
}
