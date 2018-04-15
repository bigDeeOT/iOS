//
//  LoadRequests.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/14/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FBSDKLoginKit
import UIKit

class LoadRequests {
    var ref: DatabaseReference!
    static var gRef: DatabaseReference!
    static var requestList = [RideRequest]()
    static var needToLoad = true
    var requestPage: RequestPageViewController!
    var loginPageDelegate:  MightLoginViewController!
    static var firstPageBoundarySet = false
    var requestPageSize: UInt = 10
    var requestPageBoundary: String!
    static var rideDetailPage: RideDetailViewController!
    static var numberOfRequestsInFirebase = 0
    static var numberOfRequestsLoaded = 0
    static var requestEditedLocally: String?
    static var recentlyDeletedRequest: String?
    static var recentOffer: String?
    static var tabBarController: UITabBarController?
    
    static func newMessage() {
        guard let tabBarCon = tabBarController else {return}
        if let number = tabBarCon.tabBar.items![2].badgeValue {
            var int = Int(number)!
            int += 1
            tabBarCon.tabBar.items![2].badgeValue = String(int)
        } else {
            tabBarCon.tabBar.items![2].badgeValue = "1"
        }
    }
    
    static func clearMessagesNotification() {
        guard let tabBarCon = tabBarController else {return}
        tabBarCon.tabBar.items![2].badgeValue = nil
    }
    
    static func clear() {
        for request in requestList {
            if request.unique != nil {
                removeOfferListener(requestNumber: request.unique!)
            }
        }
        gRef.child("Requests").removeAllObservers()
        if let userUnique = RequestPageViewController.userName?.unique {
            gRef.child("Requests by Users/\(userUnique)/Requests").removeAllObservers()
        }
        requestList.removeAll()
        numberOfRequestsLoaded = 0
        numberOfRequestsInFirebase = 0
        firstPageBoundarySet = false
        // loadRequestsFullOfJunk()
        // now call startListening() after calling clear()
    }
    
    func get() -> [RideRequest] {
        return LoadRequests.requestList
    }
    
    static func addRequestToList(_ request: RideRequest){
        LoadRequests.requestList.append(request)
    }
    
    static func addOldRequestToList(_ request: RideRequest) {
        LoadRequests.requestList.insert(request, at: 0)
    }
    
    static func add(request: RideRequest) {
        addRequestToList(request)
        let autoID = LoadRequests.gRef.child("Requests").childByAutoId().key
        LoadRequests.gRef.child("Requests/\(autoID)").setValue(request.info)
        LoadRequests.gRef.child("Requests by Users/\((request.rider?.unique)!)/Requests/\(autoID)").setValue(request.info)
        request.unique = autoID
    }
    
    static func changeRideRequestStatus(_ request: RideRequest, status: String) {
        let key1 = "State"
        let value1 = status
        let key2 = "Resolved By"
        var value2: String?
        if status == "#Resolved" {
            value2 = RequestPageViewController.userName?.unique ?? "unknown"
        } else if status == "Unresolved" {
            value2 = nil
        }
        let updateData = [
            key1 : value1,
            key2 : value2
        ]
        LoadRequests.gRef.child("Requests/\(request.unique!)").updateChildValues(updateData)
        LoadRequests.gRef.child("Requests by Users/\((request.rider?.unique)!)/Requests/\(request.unique!)").updateChildValues(updateData)
    }
    
    static func addOffer(_ offer: Offer, for rideRequest: RideRequest) {
        rideRequest.offers?.append(offer)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
        let date = dateFormatter.string(from: Date())
        let offerID = LoadRequests.gRef.child("Offers").childByAutoId().key
        LoadRequests.gRef.child("Offers/\(offerID)").setValue([
            "Driver"        : offer.driver?.unique,
            "Date"          : date,
            "ETA"           : offer.eta ?? "none",
            "Location"      : offer.location ?? "none",
            "Comment"       : offer.comment ?? "none",
            "Ride Request"  : rideRequest.unique,
            ])
        offer.unique = offerID
        rideRequest.delegate?.updateUI()
        LoadRequests.gRef.child("Requests/\(rideRequest.unique!)/Offers/\(offerID)").setValue("True")
        LoadRequests.gRef.child("Requests by Users/\((rideRequest.rider?.unique)!)/Requests/\(rideRequest.unique!)/Offers/\(offerID)").setValue("True")
    }
    
    func getNumberOfRideRequests() {
        self.ref.child("Requests").queryLimited(toLast: requestPageSize).observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {return}
            let requests = snapshot.value as! [String:Any?]
            LoadRequests.numberOfRequestsInFirebase = requests.count
            print("numberOfRequestsInFirebase is ", requests.count)
        })
    }
    
    //currently not used
    func getRequestDirectory() -> String {
        var requestDirectory = "Requests"
        let userClass = RequestPageViewController.userName?.info["Class"]
        let unique = RequestPageViewController.userName?.unique
        if (userClass == "Rider") || (userClass == "Pending Driver") {
            requestDirectory = "Requests by Users/\((unique)!)/Requests"
        }
        return requestDirectory
    }
    
    func listenForRequest() {
        let requestDirectory = "Requests"
        self.ref.child(requestDirectory).queryLimited(toLast: requestPageSize).observe(.childAdded, with: { [weak self] (snapshot) in
            if LoadRequests.firstPageBoundarySet == false {
                LoadRequests.firstPageBoundarySet = true
                self?.requestPageBoundary = snapshot.key
            }
            guard LoadRequests.requestList.last?.unique != snapshot.key else {
                //If current user just made a request
                self?.listenForOffer((LoadRequests.requestList.last)!)
                return
            }
            guard let riderUnique = (snapshot.value as? [String:Any])?["Rider"] as? String else {return}
            let request = self?.createRideRequest(from: snapshot.key, with: snapshot.value as! [String : Any], isNew: true)
            self?.setRiderForRideRequest(from: riderUnique, with: request!)
        })
    }
    
    func listenForMoreRequest() {
        let requestDirectory = "Requests"
        ref.child(requestDirectory).queryOrderedByKey().queryLimited(toLast: requestPageSize).queryEnding(atValue: requestPageBoundary).observeSingleEvent(of: .value, with: { [weak self] (snap) in
            guard snap.exists() else {return}
            guard snap.children.allObjects.count > 1 else {self?.requestPage.loadedAllCells = true; return}
            let keyFromLastPage = (self?.requestPageBoundary)!
            for child in snap.children {
                let key = (child as! DataSnapshot).key
                let requestInfo = (child as! DataSnapshot).value as! [String:Any]
                if key == keyFromLastPage {continue}
                if key < (self?.requestPageBoundary)! { self?.requestPageBoundary = key }
                guard let riderUnique = requestInfo["Rider"] as? String else {return}
                let request = self?.createRideRequest(from: key, with: requestInfo, isNew: false)
                self?.setRiderForRideRequest(from: riderUnique, with: request!)
            }
        })
    }
    
    func setRiderForRideRequest(from riderUnique: String, with request: RideRequest) {
        ref.child("Users/\(riderUnique)").observeSingleEvent(of: .value, with: { [weak self] (snapShotUser) in
            LoadRequests.numberOfRequestsLoaded += 1
            if LoadRequests.numberOfRequestsLoaded == 10 {
                print("number of requests loaded is ten")
            }
            guard snapShotUser.exists() else {return}
            let user = self?.pullUserFromFirebase(snapShotUser)
            request.rider = user
            //get offers
            self?.listenForOffer(request)
            self?.requestPage?.rideRequestList?.reloadData()
            self?.requestPage?.requestJustAdded = request
        })
    }
    
    func createRideRequest(from key: String, with details: [String:Any], isNew: Bool) -> RideRequest {
        let request = RideRequest()
        for (key, value) in details {
            if let value = value as? String {
                request.info[key] = value
            }
        }
        request.unique = key
        if isNew {
            LoadRequests.addRequestToList(request)
        } else {
            LoadRequests.addOldRequestToList(request)
        }
        //if request is resolved, get user who resolved it
        addResolvedBy(request)
        return request
    }
    
    func addResolvedBy(_ request: RideRequest) {
        if request.info["Resolved By"] != nil {
            ref.child("Users").child(request.info["Resolved By"]!).observeSingleEvent(of: .value, with: { [weak self] (snapshotUser) in
                request.resolvedBy = self?.pullUserFromFirebase(snapshotUser)
                self?.requestPage?.rideRequestList?.reloadData()
                request.delegate?.updateUI()
            })
        }
    }
    
    func listenForOffer(_ request: RideRequest) {
        self.ref.child("Requests/\(request.unique!)/Offers").observe(.childAdded, with: { [weak self] (offerSnapshot) in
            let offerUnique = offerSnapshot.key
            guard offerUnique != request.offers?.last?.unique else {return}
            guard offerUnique != LoadRequests.recentOffer else {return}
            LoadRequests.recentOffer = offerUnique
            self?.ref.child("Offers/\(offerUnique)").observeSingleEvent(of: .value, with: { (offerDetailSnapshot) in
                guard offerDetailSnapshot.exists() else { return }
                let offerDetails = offerDetailSnapshot.value as! [String:Any]
                let offer = Offer()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
                offer.date = dateFormatter.date(from: offerDetails["Date"] as! String)
                let offerETA = offerDetails["ETA"] as? String
                let location = offerDetails["Location"] as? String
                offer.location = location
                offer.eta = offerETA
                if offerETA == "none" { offer.eta = nil }
                offer.comment = offerDetails["Comment"] as? String
                offer.unique = offerUnique
                Timer.scheduledTimer(withTimeInterval: 60*20, repeats: false, block: { (time) in
                   // Doesn't work for some reason
                    self?.ref.child("Requests/\(request.unique!)/Offers").removeAllObservers()
                })
                //get user who made offer
                let offerDriverUnique = offerDetails["Driver"] as! String
                self?.ref.child("Users/\(offerDriverUnique)").observeSingleEvent(of: .value, with: { (offerDriverSnapshot) in
                    let offerDriver = self?.pullUserFromFirebase(offerDriverSnapshot)
                    offer.driver = offerDriver
                    request.offers?.append(offer)
                    request.delegate?.reload()
                    self?.requestPage?.rideRequestList?.reloadData()
                    request.delegate?.updateUI()
                })
            })
        })

    }
    
    static private func removeOfferListener(requestNumber unique: String) {
        LoadRequests.gRef.child("Requests/\(unique)/Offers").removeAllObservers()
    }
    
    func listenForRequestDeleted() {
        ref.child("Requests").observe(.childRemoved, with: { (snapshot) in
            let unique = snapshot.key
            guard unique != LoadRequests.recentlyDeletedRequest else {return}
            for i in 0..<LoadRequests.requestList.count {
                if LoadRequests.requestList[i].unique == unique {
                    //if currently viewing the request, go back to main page
                    LoadRequests.requestList[i].delegate?.requestWasDeleted()
                    LoadRequests.requestList.remove(at: i)
                    self.requestPage.rideRequestList.reloadData()
                    break
                }
            }
            
        })
    }
    
    func listenForRequestEdited() {
        ref.child("Requests").observe(.childChanged, with: { [weak self] (snapshot) in
            let detail = snapshot.value as! [String:Any]
            var request: RideRequest?
            let id = snapshot.key
            guard LoadRequests.requestEditedLocally != id else {
                print("Trying to update a request that was edited locally. Now returning")
                LoadRequests.requestEditedLocally = nil
                return
            }
            for req in LoadRequests.requestList {
                if req.unique == id {
                    request = req
                    break
                }
            }
            guard request != nil else {print("bad edit observe");return}
            for (key, value) in detail {
                if let value = value as? String {
                    request?.info[key] = value
                }
            }
            self?.addResolvedBy(request!)
            //Now update the user
            self?.ref.child("Users").child((request?.rider?.unique)!).observeSingleEvent(of: .value, with: { [weak self] (snapshotUser) in
                let profileDetails = request?.rider?.profileDetails
                request?.rider = self?.pullUserFromFirebase(snapshotUser)
                request?.rider?.profileDetails = profileDetails
                request?.rider?.profileDetails?.updateUI()
            })
            if (request?.offers?.isEmpty)! {self?.listenForOffer(request!)}
            self?.requestPage.rideRequestList.reloadData()
            request?.delegate?.updateUI()
        })
    }
    
    func configureFirebase() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        if LoadRequests.needToLoad {
            //       LoadRequests.loadRequestsFullOfJunk()
            LoadRequests.needToLoad = false
        }
        ref = Database.database().reference()
        LoadRequests.gRef = ref
    }
    
    func login(fromViewController vc: UIViewController) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: vc) {[weak self]  (result, err) in
            if err != nil {
                print("FB login failed with error: ", err ?? "")
                return
            }
            guard let accessToken = FBSDKAccessToken.current()?.tokenString else {
                print("Facebook accessToken is nil")
                return
            }
            //self?.loginPageDelegate.finishedLogin()
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
            //sign in with firebase
            self?.configureFirebase()
            Auth.auth().signIn(with: credential) { [weak self] (user, err) in
               self?.loginPageDelegate.finishedLogin()
                if err != nil {
                    print("\ncould not authenticate firebase fb signin",err ?? "")
                    self?.requestPage?.logout()
                    return
                }
                print("Firebase user ID is ",Auth.auth().currentUser?.uid ?? "error with firebase login ID in LoadRequest.login()")
                self?.checkIfUserExists()
            }
        }
    }
    
    
    func setNotificationToken(_ firebaseID: String) {
        let token = Messaging.messaging().fcmToken
        ref.child("Users").child("\(firebaseID)/pushToken").setValue(token)
        
    }
    
    func checkIfUserExists() {
        configureFirebase()
        guard let firebaseID = Auth.auth().currentUser?.uid else {
            print("not logged in to firebase. huge error")
            return
        }
        
        self.ref.child("Users").child(firebaseID).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard snapshot.exists() else {
                print("user does not exist in firebase database", firebaseID)
                self?.createNewUserInFirebase(firebaseID)
                return
            }
            self?.setNotificationToken(firebaseID)
            let user = self?.pullUserFromFirebase(snapshot)
            RequestPageViewController.userName = user
            guard user?.info["Class"] != "Banned" else { self?.requestPage.logout(); return }
            self?.startListening()
            self?.requestPage?.rideRequestList?.reloadData()
        })
    }
    
    private func pullUserFromFirebase(_ snapshot: DataSnapshot) -> User {
        let userInfo = snapshot.value as! [String: String]
        let user = User(userInfo)
        user.unique = snapshot.key
        return user
    }
    
    private func createNewUserInFirebase(_ firebaseID: String) {
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start {[weak self] (connection, result, err) in
            if err != nil {
                print("failed to print out graph request", err ?? "")
                return
            }
            let fbInfo = result as! [String:String]
            let picURL = "http://graph.facebook.com/\(fbInfo["id"]!)/picture?type=large"
            let user = User(url: picURL, name: fbInfo["name"]!)
            user.unique = firebaseID
            self?.ref.child("Users").child(firebaseID).setValue(user.info)
            self?.setNotificationToken(firebaseID)
            RequestPageViewController.userName = user
            self?.startListening()
            self?.requestPage.rideRequestList.reloadData()
        }
    }
    
    func startListening() {
        listenForRequest()
        listenForRequestDeleted()
        listenForRequestEdited()
        listenForUserChanges()
    }
    
    func listenForUserChanges() {
        guard let userUnique = RequestPageViewController.userName?.unique else {print("not listening for user changes");return}
        LoadRequests.gRef.child("Users").child(userUnique).observe(.childChanged, with: { (snapshot) in
            let user = RequestPageViewController.userName
            user?.info[snapshot.key] = snapshot.value as? String
            user?.profileDetails?.updateUI()
            if snapshot.key == "Class" {
                user?.profileDetails?.logout()
            }
        })
    }
    
    static func uploadCollage(_ image: UIImage, delegate: BottomProfileViewController) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("error uploading image, no uid")
            return
        }
        let refStore = Storage.storage().reference().child("\(uid)/Collage.jpg")
        let imageData = UIImageJPEGRepresentation(image, 0.1)
        refStore.putData(imageData!, metadata: nil) { (meta, err) in
            if err != nil {
                print("error uploading image data ", err ?? "")
                return
            }
            delegate.spinner.stopAnimating()
            delegate.collage.alpha = 1
            print(meta ?? "no meta")
            let url = String(describing: (meta?.downloadURL())!)
            LoadRequests.gRef.child("Users").child(uid).child("Collage URL").setValue(url)
            RequestPageViewController.userName?.info["Collage URL"] = url
            let collageHeight = String(describing: image.size.height)
            LoadRequests.gRef.child("Users").child(uid).child("Collage Height").setValue(collageHeight)
            RequestPageViewController.userName?.info["Collage Height"] = collageHeight
            let collageWidth = String(describing: image.size.width)
            LoadRequests.gRef.child("Users").child(uid).child("Collage Width").setValue(collageWidth)
        }
    }
    
    static func removeRideRequest(_ ride: RideRequest) {
        guard ride.unique != nil else {return}
        LoadRequests.recentlyDeletedRequest = ride.unique
        LoadRequests.gRef.child("Requests").child(ride.unique!).child("Offers").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let offers = snapshot.value as? [String:String]
                for (offer, _) in offers! {
                    LoadRequests.gRef.child("Offers").child(offer).removeValue()
                }
                LoadRequests.removeOfferListener(requestNumber: ride.unique!)
            }
            if ride.info["State"] == "#Resolved" {
                ride.rider?.decrementVariable("Rides Taken")
                ride.resolvedBy?.decrementVariable("Rides Given")
            }
            removeRequestInList(ride.unique!)
            LoadRequests.gRef.child("Requests").child(ride.unique!).removeValue()
            LoadRequests.gRef.child("Requests by Users/\((ride.rider?.unique)!)/Requests/\(ride.unique!)").removeValue()
            LoadRequests.rideDetailPage.performSegue(withIdentifier: "deleteRequest", sender: nil)
        })
    }
    
    static func removeRequestInList(_ unique: String) {
        for i in 0..<LoadRequests.requestList.count {
            if LoadRequests.requestList[i].unique == unique {
                LoadRequests.requestList.remove(at: i)
                break
            }
        }
    }
    
    static func updateUser(user: User) {
        let userID = user.unique!
        LoadRequests.gRef.child("Users/\(userID)").setValue(user.info)
        if let Class = user.info["Class"] {
                LoadRequests.gRef.child("\(Class)s/\(userID)").setValue(user.info)
        }
        user.profileDetails?.updateUI()
    }
    
    
    static private func loadRequestsFullOfJunk() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
        let date = dateFormatter.date(from: "07-07-2017 10:08:13 am")
        
        var rider = User(url: URL(string: "http://i.imgur.com/ezZRRss.jpg")!, name: "Donald J Trump")
        rider.info["Profile Pic URL"] = "http://i.imgur.com/ezZRRss.jpg"
        rider.phone = "512 686-7920"
        rider.info["Name"] = rider.name
        var request = RideRequest(rider: rider)
        request.text = "Airport to Capitol please"
        request.info["Text"] = "Airport to Capitol please"
        request.date = date
        request.info["Date"] = "07-07-2017 2:52:33 pm"
        request.ETA = "ETA: 9 min"
        request.state = RideRequest.State.canceled
        request.info["State"] = "#Canceled"
        request.unique = "E"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/9QBGS2m.jpg")!, name: "Gregory Fenves")
        rider.info["Profile Pic URL"] = "http://i.imgur.com/9QBGS2m.jpg"
        rider.phone = "512 686-7920"
        rider.info["Name"] = rider.name
        request = RideRequest(rider: rider)
        request.text = "Redbud to UT asap"
        request.info["Text"] = "Redbud to UT asap"
        request.date = date
        request.info["Date"] = "07-07-2017 11:49:10 am"
        request.ETA = "ETA: 9 min"
        request.info["State"] = "Unresolved"
        request.unique = "D"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/1jP1Zwv.jpg")!, name: "Asher Lostak")
        rider.info["Profile Pic URL"] = "http://i.imgur.com/qbMs1s6.jpg"
        rider.phone = "512 686-7920"
        rider.info["Name"] = rider.name
        request = RideRequest(rider: rider)
        request.text = "Hey guys I have a favor to ask. I don't know if this is the right place but is it possible for someone to pick up my dog from my apartment and bring him to the vet? I'm so worried about him please help!"
        request.info["Text"] = "Riverside to Airport\nAnyone nearby? I'm late for my flight! ✈️"
        request.date = date
        request.info["Date"] = "07-07-2017 1:01:13 pm"
        request.ETA = "ETA: 9 min"
        request.state = RideRequest.State.resolved
        request.info["State"] = "#Resolved"
        request.unique = "C"
        LoadRequests.requestList.append(request)
        

        
        rider = User(url: URL(string: "http://i.imgur.com/dSFFSzV.jpg")!, name: "Bobby Carlisle")
        rider.info["Profile Pic URL"] = "http://i.imgur.com/dSFFSzV.jpg"
        rider.phone = "512 686-7920"
        rider.info["Name"] = rider.name
        request = RideRequest(rider: rider)
        request.text = "Pickup domain to riveride"
        request.info["Text"] = "Pickup domain to downtown\nGot a big day today, lets roll 😎"
        request.date = date
        request.info["Date"] = "07-07-2017 11:48:41 am"
        request.ETA = "ETA: 9 min"
        request.state = RideRequest.State.resolved
        request.info["State"] = "#Resolved"
        request.unique = "B"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/BLlMnuQ.jpg")!, name: "Jennifer Bezos")
        rider.info["Profile Pic URL"] = "http://i.imgur.com/BLlMnuQ.jpg"
        rider.phone = "512 686-7920"
        rider.info["Name"] = rider.name
        request = RideRequest(rider: rider)
        request.text = "Hyde Park to Zilker"
        request.info["Text"] = "Hyde Park to Zilker"
        request.date = date
        request.info["Date"] = "07-07-2017 10:08:13 am"
        request.ETA = "ETA: 9 min"
        request.state = RideRequest.State.resolved
        request.info["State"] = "#Resolved"
        request.unique = "A"
        LoadRequests.requestList.append(request)
    }

    
}
