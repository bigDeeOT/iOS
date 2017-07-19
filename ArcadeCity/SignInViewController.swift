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
    
    @IBOutlet weak var privilege: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        textBox.endEditing(true)
    }
    
    @IBAction func go(_ sender: UIButton) {
        if let text = textBox.text {
            if text.characters.count >= 2 {
                let user = User(url: URL(string: "http://img.wennermedia.com/article-leads-horizontal/rs-18960-apes-1800-1404228817.jpg")!, name: textBox.text!)
                
                switch privilege.selectedSegmentIndex {
                case 1: user.privilege = .driver
                case 2: user.privilege = .moderator
                case 3: user.privilege = .administrator
                default: user.privilege = .rider
                }
                user.collage = URL(string: "http://i.imgur.com/Oo6YpWJ.jpg")!
                RequestPageViewController.userName = user
                performSegue(withIdentifier: "unwindToRequestPage", sender: nil)
            }
        }
    }
}
