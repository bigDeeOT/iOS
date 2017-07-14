//
//  RequestPageViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/13/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class RequestPageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var rideRequestList: UICollectionView!
    
    var reuseIdentifier = "rideRequest"

    override func viewDidLoad() {
        super.viewDidLoad()
        rideRequestList.delegate = self
        rideRequestList.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let rider = Rider(url: URL(string: "http://www.history.com/s3static/video-thumbnails/AETN-History_Prod/74/192/History_Speeches_2001_Booker_T_Washington_Race_Relations_still_624x352.jpg")!, n: "Booker T Washington")
        let request = RideRequest(r: rider)
        request.text = "Pickup domain to riveride"
        if let cell = cell as? RideRequestCollectionViewCell {
            cell.rideRequest = request
        }
        return cell
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
