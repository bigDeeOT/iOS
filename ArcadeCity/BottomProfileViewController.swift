//
//  BottomProfileViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/25/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class BottomProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var collage: UIImageView!
    var user: User?
    var maxImageSize = CGSize(width: UIScreen.main.bounds.width, height: 115)
    var containingView: ProfileViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
        collage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(collageOptions)))
        collage.isUserInteractionEnabled = true
        updateCollageSize()
        spinner.hidesWhenStopped = true
        spinner.stopAnimating()
    }
    
    func updateCollageSize() {
        collage.frame.size = ImageResize.getNewSize(currentSize: collage.image?.size, maxSize: maxImageSize)
        collage.frame.origin.x = (UIScreen.main.bounds.width / 2) - (collage.frame.size.width / 2)
    }
    
    func collageOptions() {
        let actionSheet = UIAlertController(title: "View image or upload new one", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let uploadAction = UIAlertAction(title: "Upload", style: .default) { (action) in
            print(action)
            self.getNewCollage()
        }
        let viewAction = UIAlertAction(title: "View", style: .default) { (action) in
            self.containingView?.performSegue(withIdentifier: "viewImage", sender: self.collage)
        }
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(viewAction)
        actionSheet.addAction(uploadAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    func getNewCollage() {
        spinner.startAnimating()
        collage?.alpha = 0.2
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImageFromPicker = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if let selectedImageFromPicker = selectedImageFromPicker {
            collage.image = selectedImageFromPicker
            updateCollageSize()
            LoadRequests.uploadCollage(selectedImageFromPicker, delegate: self)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        spinner.stopAnimating()
        print("user canceled image pic")
        dismiss(animated: true, completion: nil)
        collage?.alpha = 1
    }

    private func loadImage() {
        if user?.info["Collage URL"] != nil {
            collage.image = UIImage(named: "loading")
        }
        guard let collageURL = RequestPageViewController.userName?.info["Collage URL"] else {return}
        if let url = URL(string:collageURL) {
            DispatchQueue.global(qos: .default).async {
                [weak self] in
                if let imageData = NSData(contentsOf: url) {
                    DispatchQueue.main.async {
                        self?.collage.isHidden = false
                        self?.collage?.image = UIImage(data: imageData as Data)
                        self?.collage?.layer.borderWidth = 1
                        self?.collage?.layer.borderColor = UIColor.lightGray.cgColor
                        self?.updateCollageSize()
                    }
                }
            }
        }
    }

}
