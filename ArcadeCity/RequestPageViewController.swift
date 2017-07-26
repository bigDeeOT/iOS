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
    var pendingRequest: RideRequest?
    var cellWasViewed = [Bool]()
     @IBOutlet weak var rideRequestList: UITableView!
    @IBOutlet weak var addRequest: UIBarButtonItem!
    var reuseIdentifier = "rideRequest"
    var tableBackgroundColor = UIColor(red:0.86, green:0.87, blue:0.87, alpha:1.0)
    var justSignedIn: Bool = false
    var fbButton: UIBarButtonItem!
    var menuButton: UIBarButtonItem!
    var addButton: UIBarButtonItem!
    var hadToLogIn = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rideRequestList.delegate = self
        rideRequestList.dataSource = self
        requestList = loadRequests.get()
        setNavBarButton()
        style()
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
            navigationItem.leftBarButtonItem = menuButton
            navigationItem.rightBarButtonItem = addButton
            navigationController?.navigationBar.barTintColor = UIColor(red:0.16, green:0.46, blue:0.75, alpha:1.0)
            navigationController?.navigationBar.isTranslucent = true

        }
    }
    
    func removeLoginPage() {
        if Auth.auth().currentUser?.uid != nil {
            print("removing login page")
            loginPage?.spinner.stopAnimating()
            loginPageView.isHidden = true
            tabBarNavBarLogic()
            addRequestButtonLogic()
        }
    }
    
    private func style() {
        let navBar = navigationController?.navigationBar
        view.backgroundColor = tableBackgroundColor
        navBar?.isTranslucent = true
        navBar?.barTintColor = UIColor(red:0.16, green:0.46, blue:0.75, alpha:1.0)
        let tabBar = tabBarController?.tabBar
        tabBar?.barTintColor = UIColor.white
        
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
        menuButtonLogic()
        LoadRequests.gRef.child("Requests").removeAllObservers()
       // isListening = false
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
        //menuButtonLogic()
        addRequestButtonLogic()
        rideRequestList.reloadData()
      /*
        if (RequestPageViewController.userName != nil) {
            print("adding request observer in view will appear")
            loadRequests.listenForRequest()
            isListening = true
        }
 */
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
            if !loginPageView.isHidden {
                checkIfLastRequestLoaded(indexPath.section)
            }
        }
        
        return cell
    }
    
    
    func checkIfLastRequestLoaded(_ section: Int) {
        if loadRequests.numberOfRequestsLoaded >= loadRequests.numberOfRequestsInFirebase {
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

        if let vc = segue.destination as? LoginViewController {
            vc.requestPage = self
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
