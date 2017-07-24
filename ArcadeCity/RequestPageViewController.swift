//
//  RequestPageViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/13/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class RequestPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, OfferRide {
    
    var requestList = [RideRequest]()
    var loadRequests = LoadRequests()
    static var userName: User?
    var pendingRequest: RideRequest?
    var cellWasViewed = [Bool]()
     @IBOutlet weak var rideRequestList: UITableView!
    @IBOutlet weak var addRequest: UIBarButtonItem!
    var reuseIdentifier = "rideRequest"
    var tableBackgroundColor = UIColor(red:0.86, green:0.87, blue:0.87, alpha:1.0)
    var justSignedIn: Bool = false
    var fbButton: UIBarButtonItem!
    var menuButton: UIBarButtonItem!
    var isListening: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rideRequestList.delegate = self
        rideRequestList.dataSource = self
        requestList = loadRequests.get()
        setNavBarButton()
        style()
        addRequestButtonLogic()
        loadRequests.requestPage = self
        loadRequests.checkIfUserExists()
        if Auth.auth().currentUser?.uid != nil {
            loadRequests.listenForRequest()
            isListening = true
        }
    }
    
    private func style() {
        let bar = navigationController?.navigationBar
        view.backgroundColor = tableBackgroundColor
        bar?.isTranslucent = true
        bar?.barTintColor = UIColor(red:0.16, green:0.46, blue:0.75, alpha:1.0)
        //bar?.setBackgroundImage(UIImage(), for: .default)
        //bar?.shadowImage = UIImage()
        //bar?.clipsToBounds = true
        
        rideRequestList.backgroundColor = tableBackgroundColor
        rideRequestList.showsVerticalScrollIndicator = false
        rideRequestList.rowHeight = UITableViewAutomaticDimension
        rideRequestList.estimatedRowHeight = 128
       // let image = UIImage(named: "logo")
      //  navigationItem.titleView = UIImageView(image: image)
    }
    
    private func setNavBarButton() {
        let fb = UIButton()
        fb.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        fb.setImage(UIImage(named: "fbLoginNavBar"), for: .normal)
        fb.addTarget(self, action: #selector(login), for: .touchUpInside)
        fbButton = UIBarButtonItem()
        fbButton.customView = fb
        
        let menu = UIButton()
        menu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        menu.setImage(UIImage(named: "menuNavBar"), for: .normal)
        menu.addTarget(self, action: #selector(menuNavBar), for: .touchUpInside)
        menuButton = UIBarButtonItem()
        menuButton.customView = menu
        menuButtonLogic()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func login() {
        loadRequests.login(self)
        performSegue(withIdentifier: "waitingForDatabase", sender: nil)
    }

    
    func menuNavBar() {
        logout()
    }
    
    func logout() {
        FBSDKLoginManager().logOut()
        do {
            try Auth.auth().signOut()
        } catch { print("error with firebase logout")}
        RequestPageViewController.userName = nil
        addRequest.isEnabled = false
        menuButtonLogic()
        LoadRequests.gRef.child("Requests").removeAllObservers()
        isListening = false
        LoadRequests.clear()
        rideRequestList.reloadData()
    }
    
    private func addRequestButtonLogic() {
        if Auth.auth().currentUser?.uid == nil {
            addRequest.isEnabled = false
        } else {
            addRequest.isEnabled = true
        }
    }
    
    private func menuButtonLogic() {
        if Auth.auth().currentUser?.uid == nil {
            navigationItem.leftBarButtonItem = fbButton
        } else {
            navigationItem.leftBarButtonItem = menuButton
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        menuButtonLogic()
        addRequestButtonLogic()
        rideRequestList.reloadData()
        
        if (isListening == false) && (RequestPageViewController.userName != nil) {
            print("adding request observer in view will appear")
            loadRequests.listenForRequest()
            isListening = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (isListening == true) && (RequestPageViewController.userName == nil) {
            print("removing observers in view will disappear")
            LoadRequests.gRef.child("Requests").removeAllObservers()
            isListening = false
        }
    }
    
    /* Spacing between cells*/
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 15
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 15))
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 15))
        view.backgroundColor = UIColor.clear
        return view
    }
    /* End of Spacing between cells*/
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return LoadRequests.requestList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("cellForRowAt indexPath")
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if let cell = cell as? RequestPageTableViewCell {
            guard indexPath.section <= (LoadRequests.requestList.count - 1) else {return cell}
            
            let rideRequest = LoadRequests.requestList[LoadRequests.requestList.count - 1 - indexPath.section]
            cell.rideRequest = rideRequest
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.requestPageDelegate = self
            cell.layer.cornerRadius = 4
            cell.layer.masksToBounds = false
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 1, height: 1)
            cell.layer.shadowOpacity = 0.3
        }
        return cell
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RequestPageTableViewCell {
            if RequestPageViewController.userName != nil {
                performSegue(withIdentifier: "rideRequestDetails", sender: cell)
            }
        }
    }
    
    func segueToAddCollage(rideRequest: RideRequest) {
        if (rideRequest.state == RideRequest.State.unresolved) {
            performSegue(withIdentifier: "postCollage", sender: rideRequest)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RideDetailViewController {
            if let cell = sender as? RequestPageTableViewCell {
                vc.rideRequest = cell.rideRequest
            }
        }
        if let vc = segue.destination as? PostCollageViewController {
            if let request = sender as? RideRequest {
                vc.rideRequest = request
            }
        }
        if let vc = segue.destination as? WaitingForDatabaseViewController {
            loadRequests.waitingPage = vc
        }
        
    }

    @IBAction func unwindToRequestPage(segue: UIStoryboardSegue) {
        navigationController?.isNavigationBarHidden = false
    }

}

protocol OfferRide {
    //this is just so we can segue from tableView cell
    func segueToAddCollage(rideRequest: RideRequest)
}
