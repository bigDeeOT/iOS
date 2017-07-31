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
    

    @IBOutlet weak var loginPageView: UIView!
    var loginPage: LoginViewController?
    var requestList = [RideRequest]()
    var loadRequests = LoadRequests()
    static var userName: User?
    static var profileDetails: MiddleProfileTableViewController?
    var pendingRequest: RideRequest?
    var requestJustAdded: RideRequest?
    var cellWasViewed = [Bool]()
     @IBOutlet weak var rideRequestList: UITableView!
    @IBOutlet weak var addRequest: UIBarButtonItem!
    var reuseIdentifier = "rideRequest"
   // var tableBackgroundColor = UIColor(red:0.86, green:0.87, blue:0.87, alpha:1.0)
    var tableBackgroundColor = UIColor.clear
    var justSignedIn: Bool = false
    var fbButton: UIBarButtonItem!
    var menuButton: UIBarButtonItem!
    var addButton: UIBarButtonItem!
    var hadToLogIn = false
    var unwindedNowGoToRideDetail = false
    var justClickOfferRide = false
    var navBarColor = UIColor(red:0.16, green:0.46, blue:0.75, alpha:1.0)
    static var this: RequestPageViewController?
    var setLocation = SetLocation()
    var secondsWaitingForETAToLoad = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rideRequestList.delegate = self
        rideRequestList.dataSource = self
        style()
        requestList = loadRequests.get()
        addRequestButtonLogic()
        loadRequests.requestPage = self
        loadRequests.getNumberOfRideRequests()
        if Auth.auth().currentUser?.uid != nil {
            loginPage?.loginButton.isHidden = true
            loadRequests.checkIfUserExists()
        } else {
            hadToLogIn = true
        }
        tabBarNavBarLogic()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black]
        RequestPageViewController.this = self
    }
    
    func tabBarNavBarLogic() {
        if loginPageView.isHidden == false {
            
            tabBarController?.tabBar.isHidden = true
            //navigationController?.navigationBar.isHidden = true
            navigationItem.leftBarButtonItem = nil
            addButton = navigationItem.rightBarButtonItem
            navigationItem.rightBarButtonItem = nil
            navigationController?.navigationBar.barTintColor = UIColor.black
            navigationController?.navigationBar.isTranslucent = false
 
        } else {
            tabBarController?.tabBar.isHidden = false
           // navigationController?.navigationBar.isHidden = false
           // navigationItem.leftBarButtonItem = menuButton
            navigationItem.rightBarButtonItem = addButton
            navigationController?.navigationBar.barTintColor = navBarColor
            navigationController?.navigationBar.isTranslucent = false

        }
    }
    
    func removeLoginPage() {
        if Auth.auth().currentUser?.uid != nil {
            loginPage?.spinner.stopAnimating()
            loginPageView.isHidden = true
            tabBarNavBarLogic()
            addRequestButtonLogic()
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
            rideRequestList.reloadData() //may have to delete this
        }
    }
    
    private func style() {
        print("style called")
        let navBar = navigationController?.navigationBar
        //view.backgroundColor = tableBackgroundColor
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        //navBar?.barTintColor = UIColor(red:0.16, green:0.46, blue:0.75, alpha:1.0)
        navBar?.barTintColor = navBarColor
        navBar?.tintColor = UIColor.white
        navBar?.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navBar?.setValue(true, forKey: "hidesShadow")
        navBar?.isTranslucent = false
        let tabBar = tabBarController?.tabBar
        tabBar?.barTintColor = UIColor.white
        rideRequestList.backgroundColor = tableBackgroundColor
        rideRequestList.showsVerticalScrollIndicator = false
        rideRequestList.rowHeight = UITableViewAutomaticDimension
        rideRequestList.estimatedRowHeight = 128
       //let image = UIImage(named: "logo")
      //navigationItem.titleView = UIImageView(image: image)
    }
    
    func login() {
        loadRequests.login(self)
        loginPage?.spinner.startAnimating()
        loginPage?.loginButton.isHidden = true
        
       // Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(RequestPageViewController.fixLoginIfUserCanceled), userInfo: nil, repeats: false)
       // isListening = true
    }
    
    func fixLoginIfUserCanceled() {
        print("executing fix login if canceled")
            loginPage?.spinner.stopAnimating()
            loginPage?.loginButton.isHidden = false
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
        LoadRequests.gRef.child("Requests").removeAllObservers()
        LoadRequests.clear()
        rideRequestList.reloadData()
        loginPageView.isHidden = false
        loginPage?.loginButton.isHidden = false
        tabBarNavBarLogic()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black]
        tabBarController?.selectedIndex = 0
    }
    
    private func addRequestButtonLogic() {
        if Auth.auth().currentUser?.uid == nil {
            addRequest.isEnabled = false
        } else {
            addRequest.isEnabled = true
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        addRequestButtonLogic()
        rideRequestList.reloadData()
        if unwindedNowGoToRideDetail == true {
            unwindedNowGoToRideDetail = false
            justClickOfferRide = true
            performSegue(withIdentifier: "rideRequestDetails", sender: pendingRequest)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
     //   if (isListening == true) && (RequestPageViewController.userName == nil) {
        if (RequestPageViewController.userName == nil) {
            print("removing observers in view will disappear")
            LoadRequests.gRef.child("Requests").removeAllObservers()
           // isListening = false
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
            //highlight new ride requests
            if LoadRequests.requestList.count > (LoadRequests.numberOfRequestsInFirebase + 5) {
                if (rideRequest.unique == requestJustAdded?.unique) && (rideRequest.unique != nil) {
                    cell.layer.borderWidth = 1
                    cell.layer.borderColor = UIColor.black.cgColor
                    requestJustAdded = nil
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (time) in
                        cell.layer.borderWidth = 0
                        cell.layer.borderColor = UIColor.white.cgColor
                    })
                }
            }
            //calculate eta?
            if rideRequest.info["Location"] != nil {
                if !ETA.shouldHideEta(rideRequest) && (rideRequest.ETA == nil) {
                    setLocation.setETA(rideRequest)
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (time) in
                        self.secondsWaitingForETAToLoad = self.secondsWaitingForETAToLoad + 1
                        print("trying to get eta for the \(self.secondsWaitingForETAToLoad) time")
                        if rideRequest.ETA != nil {
                            time.invalidate()
                            cell.etaLogic()
                            self.secondsWaitingForETAToLoad = 0
                        } else if self.secondsWaitingForETAToLoad >= 10 {
                            time.invalidate()
                            self.secondsWaitingForETAToLoad = 0
                        }
                    })
                }
            }
            if !loginPageView.isHidden {
                checkIfLastRequestLoaded(indexPath.section)
            }
        }
        
        return cell
    }
    
    
    func checkIfLastRequestLoaded(_ section: Int) {
        if LoadRequests.numberOfRequestsLoaded >= LoadRequests.numberOfRequestsInFirebase {
            if section == 4 {
                var time = 2.0
                if hadToLogIn {time = 3.0} else {time = 2.0}
                Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(RequestPageViewController.removeLoginPage), userInfo: nil, repeats: false)
            }
        }
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RequestPageTableViewCell {
            if RequestPageViewController.userName != nil {
                performSegue(withIdentifier: "rideRequestDetails", sender: cell.rideRequest)
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
            if let request = sender as? RideRequest {
                vc.rideRequest = request
                if justClickOfferRide == true {
                    justClickOfferRide = false
                    vc.justClickOfferRide = true
                }
            }
        }
        if let vc = segue.destination as? PostCollageViewController {
            if let request = sender as? RideRequest {
                vc.rideRequest = request
            }
        }
        if let vc = segue.destination as? LoginViewController {
            vc.requestPage = self
        }
        
    }

    @IBAction func unwindToRequestPage(segue: UIStoryboardSegue) {
        navigationController?.isNavigationBarHidden = false
        if segue.source is PostCollageViewController {
            unwindedNowGoToRideDetail = true
        }
    }

}

protocol OfferRide {
    //this is just so we can segue from tableView cell
    func segueToAddCollage(rideRequest: RideRequest)
}
