//
//  RequestPageViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/13/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class RequestPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var requestList = [RideRequest]()
    var loadRequests = LoadRequests()
    static var userName: User?
    var pendingRequest: RideRequest?
    var cellWasViewed = [Bool]()
    
    @IBOutlet weak var addRequest: UIBarButtonItem!
    

    @IBOutlet weak var signInButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rideRequestList.delegate = self
        rideRequestList.dataSource = self
        if let pendingRequest = pendingRequest {
            loadRequests.add(request: pendingRequest)
        }
        requestList = loadRequests.get()
        if RequestPageViewController.userName == nil {
            addRequest.isEnabled = false
        } else {
            signInButton.title = "Sign Out"
        }
        print(RequestPageViewController.userName?.name ?? "Not Signed in yet")
        let image = UIImage(named: "logo")
        navigationItem.titleView = UIImageView(image: image)
        /*
        for _ in 0..<99 {
            cellWasViewed.append(false)
        }
 */
    }
    
    @IBAction func signIn(_ sender: UIBarButtonItem) {
        if sender.title == "Sign In" {
        performSegue(withIdentifier: "signIn", sender: nil)
        } else {
            //user wants to logout
            sender.title = "Sign In"
            RequestPageViewController.userName = nil
            addRequest.isEnabled = false
        }
        
    }
    
    @IBOutlet weak var rideRequestList: UITableView!
    
    var reuseIdentifier = "rideRequest"
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestList.count
    }
    
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let cell = cell as? RideRequestCollectionViewCell {
            let rideRequest = requestList[requestList.count - 1 - indexPath.section]
            cell.rideRequest = rideRequest
            print("ride request eta in main is \(rideRequest.ETA ?? "nil value")")
            print(cell.pickUp.text ?? "")
            print(numberOfLines(rideRequest.text ?? ""))
            cell.frame.size.height = cell.frame.size.height + (20.5 * (numberOfLines(rideRequest.text!) - 1))
            cell.delegateClass = self
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if let cell = cell as? RequestPageTableViewCell {
            let rideRequest = requestList[requestList.count - 1 - indexPath.section]
            cell.rideRequest = rideRequest
            /* debug
            print("ride request eta in main is \(rideRequest.ETA ?? "nil value")")
            print(cell.pickUp.text ?? "")
            */
        }
        return cell
    }
    
    func segueToAddCollage(rideRequest: RideRequest) {
        performSegue(withIdentifier: "addCollage", sender: rideRequest)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let rideRequest = requestList[requestList.count - 1 - section]
        let flow = collectionViewLayout as! UICollectionViewFlowLayout
        var inset = flow.sectionInset
        inset.bottom = inset.bottom + (20.5 * (numberOfLines(rideRequest.text!) - 1))
        return inset
    }
    
    private func numberOfLines (_ text: String) -> CGFloat {
        let width = UIScreen.main.bounds.width * 0.8987
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat(integerLiteral: Int.max)))
        label.font = UIFont(name: ".SFUIText", size: 15)
        label.text = text
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label.frame.size.height / CGFloat(25)
        //was 20.5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? RideRequestCollectionViewCell {
            if RequestPageViewController.userName != nil {
                performSegue(withIdentifier: "rideRequestDetails", sender: cell)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RequestPageTableViewCell {
            if RequestPageViewController.userName != nil {
                performSegue(withIdentifier: "rideRequestDetails", sender: cell)
            }
        }
    }

      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
        if let vc = segue.destination as? RideDetailViewController {
            if let cell = sender as? RideRequestCollectionViewCell {
                vc.rideRequest = cell.rideRequest
            }
        }
 */
        if let vc = segue.destination as? RideDetailViewController {
            if let cell = sender as? RequestPageTableViewCell {
                vc.rideRequest = cell.rideRequest
            }
        }
        
    }


}
