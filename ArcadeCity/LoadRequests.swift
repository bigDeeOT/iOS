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

class LoadRequests {
    var ref: DatabaseReference!
    static var gRef: DatabaseReference!
    static var requestList = [RideRequest]()
    static var needToLoad = true
    var userInfo: [String:String] = [:]
    var requestPage: RequestPageViewController!
    var loginPageDelegate:  MightLoginViewController!
    static var rideDetailPage: RideDetailViewController!
    static var numberOfRequestsInFirebase = 0
    static var numberOfRequestsLoaded = 0
    static var requestEditedLocally: String?
    static var recentlyDeletedRequest: String?
    
    init() {
        if LoadRequests.needToLoad {
       LoadRequests.loadRequestsFullOfJunk()
            LoadRequests.needToLoad = false
        }
        ref = Database.database().reference()
        LoadRequests.gRef = ref
    }
    
    static func clear() {
        for request in requestList {
            if request.unique != nil {
                removeOfferListener(requestNumber: request.unique!)
            }
        }
        requestList.removeAll()
        loadRequestsFullOfJunk()
    }
    
    func get() -> [RideRequest] {
        return LoadRequests.requestList
    }
    
    static func addRequestToList(_ request: RideRequest){
        if LoadRequests.requestList.count >= 100 {
            if requestList.first?.unique != nil {
                removeOfferListener(requestNumber: (requestList.first?.unique)!)
            }
            LoadRequests.requestList.removeFirst()
        }
        LoadRequests.requestList.append(request)
    }
    
    static func add(request: RideRequest) {
        addRequestToList(request)
        let autoID = LoadRequests.gRef.child("Requests").childByAutoId().key
        LoadRequests.gRef.child("Requests/\(autoID)").setValue(request.info)
        LoadRequests.gRef.child("Requests by Users/\((request.rider?.unique)!)/Requests/\(autoID)").setValue("True")
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
    }
    
    static func addOffer(_ offer: Offer, for rideRequest: RideRequest) {
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
    }
    
    func getNumberOfRideRequests() {
        self.ref.child("Requests").queryLimited(toLast: 95).observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {return}
            let requests = snapshot.value as! [String:Any?]
            LoadRequests.numberOfRequestsInFirebase = requests.count
            print("numberOfRequestsInFirebase is ", requests.count)
        })

    }
    
    func listenForRequest() {
        self.ref.child("Requests").queryLimited(toLast: 95).observe(.childAdded, with: { [weak self] (snapshot) in
            guard LoadRequests.requestList.last?.unique != snapshot.key else {
                self?.listenForOffer((LoadRequests.requestList.last)!)
                return
            }
            let riderUnique = (snapshot.value as? [String:Any])?["Rider"] as! String
            let request = self?.pullRequestFromFirebase(snapshot)
            //get rider
            self?.ref.child("Users/\(riderUnique)").observeSingleEvent(of: .value, with: { [weak self] (snapShotUser) in
                LoadRequests.numberOfRequestsLoaded = LoadRequests.numberOfRequestsLoaded + 1
                guard snapShotUser.exists() else {return}
                let user = self?.pullUserFromFirebase(snapShotUser)
                request?.rider = user
                //get offers
                self?.listenForOffer(request!)
                self?.requestPage.rideRequestList.reloadData()
                self?.requestPage.requestJustAdded = request
            })
        })
    }
    
    func pullRequestFromFirebase(_ snapshot: DataSnapshot) -> RideRequest {
        //This function does not apply the user to the request.
        let details = snapshot.value as! [String:Any]
        let request = RideRequest()
        for (key, value) in details {
            if let value = value as? String {
                request.info[key] = value
            }
        }
        request.unique = snapshot.key
        LoadRequests.addRequestToList(request)
        //if request is resolved, get user who resolved it
        addResolvedBy(request)
        return request
    }
    
    func addResolvedBy(_ request: RideRequest) {
        if request.info["Resolved By"] != nil {
            ref.child("Users").child(request.info["Resolved By"]!).observeSingleEvent(of: .value, with: { [weak self] (snapshotUser) in
                request.resolvedBy = self?.pullUserFromFirebase(snapshotUser)
                self?.requestPage.rideRequestList.reloadData()
                request.delegate?.updateUI()
            })
        }
    }
    
    func listenForOffer(_ request: RideRequest) {
        self.ref.child("Requests/\(request.unique!)/Offers").observe(.childAdded, with: { [weak self] (offerSnapshot) in
            let offerUnique = offerSnapshot.key
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
                    self?.requestPage.rideRequestList.reloadData()
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
            self?.requestPage.rideRequestList.reloadData()
            request?.delegate?.updateUI()
        })
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
            self?.loginPageDelegate.finishedLogin()
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
            //sign in with firebase
            Auth.auth().signIn(with: credential) { [weak self] (user, err) in
                if err != nil {
                    print("\ncould not authenticate firebase fb signin",err ?? "")
                    return
                }
                print("Firebase user ID is ",Auth.auth().currentUser?.uid ?? "error with firebase login ID in LoadRequest.login()")
                self?.checkIfUserExists()
            }
        }
    }
    
    func checkIfUserExists() {
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
            let user = self?.pullUserFromFirebase(snapshot)
            RequestPageViewController.userName = user
            self?.startListening()
            self?.requestPage?.rideRequestList.reloadData()
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
            RequestPageViewController.userName = user
            self?.startListening()
            self?.requestPage.rideRequestList.reloadData()
        }
    }
    
    func startListening() {
        listenForRequest()
        listenForRequestDeleted()
        listenForRequestEdited()
    }
    
    static func uploadCollage(_ image: UIImage, delegate: BottomProfileViewController) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("error uploading image")
            return
        }
        let refStore = Storage.storage().reference().child("collage").child(uid + ".jpg")
        let imageData = UIImageJPEGRepresentation(image, 0.01)
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
