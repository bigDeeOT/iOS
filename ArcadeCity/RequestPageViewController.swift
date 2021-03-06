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
import Crashlytics

class RequestPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, OfferRide {

    @IBOutlet weak var loginPageView: UIView!
    var loadingPage: LoadingPageMain?
    var requestList = [RideRequest]()
    var loadRequests: LoadRequests!
    static var userName: User?
    static var profileDetails: MiddleProfileTableViewController?
    var pendingRequest: RideRequest?
    var requestJustAdded: RideRequest?
    var cellWasViewed = [Bool]()
     @IBOutlet weak var rideRequestList: UITableView!
    @IBOutlet weak var addRequest: UIBarButtonItem!
    let reuseIdentifier = "rideRequest"
    let emptyList = "noRideRequests"
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
    var profilePicsCache: [String : UIImage] = [:]
    var loadedAllCells = false
    var introText: UILabel?
    var refreshRequestList = true
    var lastIndexTableRefreshed = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadRequests.tabBarController = tabBarController
        rideRequestList.delegate = self
        rideRequestList.dataSource = self
        style()
        requestList = loadRequests.get()
        addRequestButtonLogic()
        loadRequests.requestPage = self
        tabBarNavBarLogic()
        RequestPageViewController.this = self
        //UIView.setAnimationsEnabled(false)           //only for debugging on simulator
        rideRequestList.tableFooterView = UIView()
        removeSlowLoadingPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        guard RequestPageViewController.userName?.info["Class"] != "Banned" else { logout(); return }
        requestJustAdded = nil
        rideRequestList.reloadData()
        navigationController?.navigationBar.isHidden = false
        if unwindedNowGoToRideDetail == true {
            unwindedNowGoToRideDetail = false
            justClickOfferRide = true
            performSegue(withIdentifier: "rideRequestDetails", sender: pendingRequest)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (RequestPageViewController.userName == nil) {
            LoadRequests.clear()
            return
        }
        //basically refreshes the ride request list
        //refreshRequestList is set to false when going to rideDetail
        if refreshRequestList == true  {
            LoadRequests.clear()
            loadRequests.startListening()
        } else {
            refreshRequestList = true
        }
        lastIndexTableRefreshed = 0
    }
    
    func addViewForNoRides() {
        guard LoadRequests.requestList.isEmpty else {
            introText?.removeFromSuperview()
            introText = nil
            return
        }
        guard introText == nil else {return}
        //introText = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        introText = UILabel()
        introText?.text = "Make your first ride request!"
        introText?.lineBreakMode = .byWordWrapping
        introText?.numberOfLines = 0
        introText?.font = UIFont(name: "System", size: 20)
        introText?.sizeToFit()
        self.view.addSubview(introText!);
    }
    
    func tabBarNavBarLogic() {
        if loginPageView.isHidden == false {

            tabBarController?.tabBar.isHidden = true
            addButton = navigationItem.rightBarButtonItem
            navigationItem.rightBarButtonItem = nil
            navigationController?.navigationBar.barTintColor = navBarColor
            navigationController?.navigationBar.isTranslucent = false
        } else {
            tabBarController?.tabBar.isHidden = false
            navigationItem.rightBarButtonItem = addButton
            navigationController?.navigationBar.barTintColor = navBarColor
            navigationController?.navigationBar.isTranslucent = false
        }
    }
    

    func removeLoadingPlaceHolder() {
        rideRequestList.reloadData()
        loginPageView.isHidden = true
        tabBarNavBarLogic()
        addRequestButtonLogic()
    }
    
    
    private func removeSlowLoadingPage() {
        guard loadRequests.showLoadingPage else {
            removeLoadingPlaceHolder()
            loadRequests.showLoadingPage = true
            return
        }
        Timer.scheduledTimer(withTimeInterval: 6, repeats: false) { (timer) in
            if self.loginPageView.isHidden == false {
                self.removeLoadingPlaceHolder()
            }
        }
    }
    
    private func style() {
        let navBar = navigationController?.navigationBar
        //setBackground()
        view.layer.contents = UIImage(named: "background")?.cgImage
        navBar?.barTintColor = navBarColor
        navBar?.tintColor = UIColor.white
        navBar?.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold)
        ]
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "navBar"))
        navBar?.setValue(true, forKey: "hidesShadow")
        navBar?.isTranslucent = false
        let tabBar = tabBarController?.tabBar
        tabBar?.barTintColor = UIColor.white
        rideRequestList.backgroundColor = tableBackgroundColor
        rideRequestList.showsVerticalScrollIndicator = false
        rideRequestList.rowHeight = UITableViewAutomaticDimension
        rideRequestList.estimatedRowHeight = 128
    }
    
    private func setBackground() {
        UIGraphicsBeginImageContext(view.frame.size)
        UIImage(named: "background")?.draw(in: view.bounds)
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        view.backgroundColor = UIColor(patternImage: backgroundImage!)
    }
    
    func login() {          // Deprecated ????????
        loadRequests.login(fromViewController: self)
    }
    
    func logout() {
        FBSDKLoginManager().logOut()
        do {
            try Auth.auth().signOut()
        } catch { print("error with firebase logout") }
        LoadRequests.clear()
        RequestPageViewController.userName = nil
        tabBarController?.tabBar.isHidden = true
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "loginVC")
        present(vc, animated: true, completion: nil)
    }
    
    
    private func addRequestButtonLogic() {
        if Auth.auth().currentUser?.uid == nil {
            addRequest.isEnabled = false
        } else {
            addRequest.isEnabled = true
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
        var count = LoadRequests.requestList.count
        if count == 0 {
            count = 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if LoadRequests.requestList.count > 0 {
          cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: emptyList, for: indexPath)
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layer.cornerRadius = 4
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 1, height: 1)
        cell.layer.shadowOpacity = 0.3
        if let cell = cell as? RequestPageTableViewCell {
            guard indexPath.section <= (LoadRequests.requestList.count - 1) else {return cell}
            let rideRequest = LoadRequests.requestList[LoadRequests.requestList.count - 1 - indexPath.section]
            cell.requestPageDelegate = self
            cell.rideRequest = rideRequest
            
            //highlight new ride requests
            if (rideRequest.unique == requestJustAdded?.unique) && (rideRequest.unique != nil) {
                requestJustAdded = nil
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.black.cgColor
                requestJustAdded = nil
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (time) in
                    cell.layer.borderWidth = 0
                    cell.layer.borderColor = UIColor.white.cgColor
                })
            }

            //calculate eta
            if rideRequest.info["Location"] != nil {
                if !ETA.shouldHideEta(rideRequest) && (rideRequest.ETA == nil) {
                    let destination = rideRequest.info["Location"] ?? "Austin"
                    setLocation.setETA(to: destination, for: cell)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section != lastIndexTableRefreshed else {return}
        if indexPath.section == (LoadRequests.requestList.count - 1) {
            lastIndexTableRefreshed = indexPath.section
            loadRequests.listenForMoreRequest()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard RequestPageViewController.userName != nil else {return}
        let cell = tableView.cellForRow(at: indexPath)
        if let cell = cell as? RequestPageTableViewCell {
                performSegue(withIdentifier: "rideRequestDetails", sender: cell.rideRequest)
        } else {
            performSegue(withIdentifier: "addRide", sender: nil)
        }
    }
    
    func segueToAddCollage(rideRequest: RideRequest) {
        if (rideRequest.state == RideRequest.State.unresolved) {
            performSegue(withIdentifier: "postCollage", sender: rideRequest)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RideDetailViewController {
            refreshRequestList = false
            if let request = sender as? RideRequest {
                vc.rideRequest = request
                vc.requestPage = self
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
        if let vc = segue.destination as? LoadingPageMain {
            vc.requestPage = self
        }
        if let vc = segue.destination as? ProfileViewController {
            vc.user = sender as? User
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
