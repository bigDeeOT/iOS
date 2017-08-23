//
//  PictureDocumentTableViewCell.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/20/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class PictureDocumentTableViewCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var title: UILabel!
    var controller: DriverDocumentationViewController!
    var maxImageSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / (4/3))
    var document: Document! {
        didSet {
            title.text = document.title
            loadPicture()
            if controller.documentsAreForEditing == true {
                if document.value != nil {
                    picture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pictureOptions)))
                } else {
                    picture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getNewPicture)))
                }
            } else {
                picture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewPicture)))
            }
            picture.isUserInteractionEnabled = true
        }
    }
    
    private func updatePictureSize() {
        picture.frame.size = ImageResize.getNewSize(currentSize: picture.image?.size, maxSize: maxImageSize)
        picture.frame.origin.x = (UIScreen.main.bounds.width - picture.frame.size.width) / 2
    }
    
    func viewPicture() {
        controller.performSegue(withIdentifier: "viewPicture", sender: picture)
    }
    
    func pictureOptions() {
        let actionSheet = UIAlertController(title: "View document or upload new one", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let uploadAction = UIAlertAction(title: "Upload", style: .default) { (action) in
            self.getNewPicture()
        }
        let viewAction = UIAlertAction(title: "View", style: .default) { (action) in
            self.viewPicture()
        }
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(viewAction)
        actionSheet.addAction(uploadAction)
        controller.present(actionSheet, animated: true, completion: nil)
    }
    
    func getNewPicture() {
        picture?.alpha = 0.2
        let picker = UIImagePickerController()
        picker.delegate = self
        controller.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImageFromPicker = info[UIImagePickerControllerOriginalImage] as? UIImage
        if let selectedImageFromPicker = selectedImageFromPicker {
            picture.image = selectedImageFromPicker
            document.valueToSave = selectedImageFromPicker
            updatePictureSize()
            picture?.alpha = 1
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        controller.dismiss(animated: true, completion: nil)
        picture?.alpha = 1
    }
    
    private func loadPicture() {
        guard let picURL = document.value else {return}
        picture.image = #imageLiteral(resourceName: "profilePicPlaceHolder")
        if let url = URL(string:picURL) {
            DispatchQueue.global(qos: .default).async {
                [weak self] in
                if let imageData = NSData(contentsOf: url) {
                    DispatchQueue.main.async {
                        self?.picture.isHidden = false
                        self?.picture.image = UIImage(data: imageData as Data)
                        self?.picture.layer.cornerRadius = 3
                        self?.picture.layer.masksToBounds = true
                        self?.updatePictureSize()
                    }
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
