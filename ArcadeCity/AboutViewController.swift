//
//  AboutViewController.swift
//  Might
//
//  Created by Dewayne Perry on 4/1/18.
//  Copyright © 2018 The University of Texas at Austin. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    var textView: UITextView!
    let textToShow = "Get a ride anywhere in the city with Might. Make a ride request and drivers will offer you a ride. Contact them and they'll head your way. All payments are handled offline so there's no third party taking a cut."

    override func viewDidLoad() {
        super.viewDidLoad()
        setupText()
    }
    
    private func setupText() {
        textView = UITextView(frame: view.frame)
        view.addSubview(textView)
        textView?.text = textToShow
        textView?.isEditable = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(red:0.16, green:0.46, blue:0.75, alpha:1.0)
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
        ]
        navigationItem.title = "About Might"
    }

}
