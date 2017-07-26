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
    var maxImageSize = CGSize(width: 400, height: 100)
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
        collage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getNewCollage)))
        collage.isUserInteractionEnabled = true
        print(collage.image?.size ?? "")
        print(collage.frame.size)
        print(ImageResize.getNewSize(currentSize: collage.image?.size, maxSize: collage.frame.size))
 
        collage.frame.size = ImageResize.getNewSize(currentSize: collage.image?.size, maxSize: maxImageSize)
    }
    
    func getNewCollage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
       // print(info)
        var selectedImageFromPicker: UIImage?
        
        if let originalImageInfo = info[UIImagePickerControllerOriginalImage] {
            selectedImageFromPicker = originalImageInfo as? UIImage
        }
        if let selectedImageFromPicker = selectedImageFromPicker {
            collage.image = selectedImageFromPicker
            
            
            print(collage.image?.size ?? "")
            print(collage.frame.size)
            print(ImageResize.getNewSize(currentSize: collage.image?.size, maxSize: maxImageSize))
            
            collage.frame.size = ImageResize.getNewSize(currentSize: collage.image?.size, maxSize: maxImageSize)

        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("user canceled image pic")
        dismiss(animated: true, completion: nil)
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
                        self?.collage.frame.size = ImageResize.getNewSize(currentSize: self?.collage.image?.size, maxSize: self?.collage.frame.size)
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
