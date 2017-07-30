//
//  TopProfileViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/25/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class TopProfileViewController: UIViewController {

    @IBOutlet weak var bio: UILabel!
    
    @IBOutlet weak var profilePic: UIImageView!
    var user: User?
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
        bio.text = user?.info["Bio"]
        bio.lineBreakMode = .byWordWrapping
        bio.numberOfLines = 0
        // Do any additional setup after loading the view.
    }

    private func loadImage() {
        if let url = URL(string: (RequestPageViewController.userName?.info["Profile Pic URL"])!) {
            DispatchQueue.global(qos: .default).async {
                [weak self] in
                if let imageData = NSData(contentsOf: url) {
                    DispatchQueue.main.async {
                        self?.profilePic?.image = UIImage(data: imageData as Data)
                        self?.profilePic?.layer.borderWidth = 1
                        self?.profilePic?.layer.borderColor = UIColor.lightGray.cgColor
                       
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
