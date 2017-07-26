//
//  BottomProfileViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/25/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class BottomProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var collage: UIImageView!
    var user: User?
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
        collage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getNewCollage)))
        collage.isUserInteractionEnabled = true
    }
    
    func getNewCollage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        print("in get new collage")
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("user canceled image pic")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadImage() {
        if let url = RequestPageViewController.userName?.collage {
            DispatchQueue.global(qos: .default).async {
                [weak self] in
                if let imageData = NSData(contentsOf: url) {
                    DispatchQueue.main.async {
                        self?.collage?.image = UIImage(data: imageData as Data)
                        self?.collage?.layer.borderWidth = 1
                        self?.collage?.layer.borderColor = UIColor.lightGray.cgColor
                        self?.collage.image = self?.collage.image?.resizedImageWithinRect(rectSize: CGSize(width: 138, height: 138))
                    }
                }
            }
        }
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
