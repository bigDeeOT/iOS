//
//  ImageViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/26/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    var image: UIImageView?
    var newImage: UIImageView?
    var hideNavigationBarOnExit = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        newImage = UIImageView(image: image?.image)
        newImage?.frame = (image?.frame)!
        scrollView.addSubview(newImage!)
        newImage?.sizeToFit()
        newImage?.frame.size = ImageResize.getNewSize(currentSize: newImage?.frame.size, maxSize: UIScreen.main.bounds.size)
        newImage?.frame.origin = CGPoint(x: 0, y: 0)
        scrollView.contentSize = (newImage?.frame.size)!
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return newImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        tabBarController?.tabBar.isHidden = true
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = hideNavigationBarOnExit
        tabBarController?.tabBar.isHidden = false
    }
    
}
