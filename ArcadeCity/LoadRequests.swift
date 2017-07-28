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
    static var rideDetailPage: RideDetailViewController!
    var numberOfRequestsInFirebase = 0
    var numberOfRequestsLoaded = 0
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
        LoadRequests.gRef.child("Requests/\(autoID)").setValue(request.keyValues)
        LoadRequests.gRef.child("Requests by Users/\((request.rider?.unique)!)/Requests/\(autoID)").setValue("True")
        request.unique = autoID
    }
    
    static func changeRideRequestStatus(_ request: RideRequest, status: String) {
        LoadRequests.gRef.child("Requests/\(request.unique!)/Status").setValue(status)
        if status == "#Resolved" {
            LoadRequests.gRef.child("Requests/\(request.unique!)/Resolved By").setValue(RequestPageViewController.userName?.name ?? "unknown")
        }
        if status == "Unresolved" {
            LoadRequests.gRef.child("Requests/\(request.unique!)/Resolved By").removeValue()
        }
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
            "Comment"       : offer.comment ?? "none",
            "Ride Request"  : rideRequest.unique,
            ])
        offer.unique = offerID
        LoadRequests.gRef.child("Requests/\(rideRequest.unique!)/Offers/\(offerID)").setValue("True")
    }
    
    func getNumberOfRideRequests() {
        self.ref.child("Requests").queryLimited(toLast: 95).observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {return}
            let requests = snapshot.value as! [String:Any?]
            self.numberOfRequestsInFirebase = requests.count
            print("numberOfRequestsInFirebase is ", requests.count)
        })

    }
    /*
    func listenForRequest() {
        self.ref.child("Requests").queryLimited(toLast: 95).observe(.childAdded, with: { [weak self] (snapshot) in
            
            
            let unique = snapshot.key
            guard LoadRequests.requestList.last?.unique != unique else {
                self?.listenForOffer((LoadRequests.requestList.last)!)
                return
            }
            let details = snapshot.value as! [String:Any]
            let request = RideRequest()
            LoadRequests.addRequestToList(request)
            request.text = details["Text"] as? String
            if details["Show ETA"] as! String == "True" {
                request.showETA = true } else { request.showETA = false }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
            let date = dateFormatter.date(from: details["Date"] as! String)
            request.date = date
            let riderUnique = details["Rider"] as! String
            request.unique = unique
            //get rider
            self?.ref.child("Users/\(riderUnique)").observeSingleEvent(of: .value, with: { [weak self] (snapShotUser) in
                self?.numberOfRequestsLoaded = (self?.numberOfRequestsLoaded)! + 1
                guard snapShotUser.exists() else {return}
                let user = self?.pullUserFromFirebase(snapShotUser)
                request.rider = user
                //get offers
                self?.listenForOffer(request)
                self?.requestPage.rideRequestList.reloadData()
            })
        })
    }
 */
    
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
                self?.numberOfRequestsLoaded = (self?.numberOfRequestsLoaded)! + 1
                guard snapShotUser.exists() else {return}
                let user = self?.pullUserFromFirebase(snapShotUser)
                request?.rider = user
                //get offers
                self?.listenForOffer(request!)
                self?.requestPage.rideRequestList.reloadData()
            })
        })
    }
    
    func pullRequestFromFirebase(_ snapshot: DataSnapshot) -> RideRequest {
        //This function does not apply the user to the request.
        let details = snapshot.value as! [String:Any]
        let request = RideRequest()
        for (key, value) in details {
            if let value = value as? String {
                request.keyValues[key] = value
            }
        }
        request.unique = snapshot.key
        LoadRequests.addRequestToList(request)
        return request
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
                offer.eta = offerETA
                if offerETA == "none" { offer.eta = nil }
                offer.comment = offerDetails["Comment"] as? String
                offer.unique = offerUnique
                //get user who made offer
                let offerDriverUnique = offerDetails["Driver"] as! String
                self?.ref.child("Users/\(offerDriverUnique)").observeSingleEvent(of: .value, with: { (offerDriverSnapshot) in
                    let offerDriver = self?.pullUserFromFirebase(offerDriverSnapshot)
                    offer.driver = offerDriver
                    request.offers?.append(offer)
                    request.delegate?.reload()
                    self?.requestPage.rideRequestList.reloadData()
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
    
    
    func login(_ vc: UIViewController) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: vc) {[weak self]  (result, err) in
            if err != nil {
                print("Custom FB login failed", err ?? "")
                return
            }
            guard let accessToken = FBSDKAccessToken.current()?.tokenString else {
                print("accessToken is nil")
                self?.requestPage.fixLoginIfUserCanceled()
                //self?.waitingPage?.go()
                return
            }
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
            if self == nil {
                print("self is nil in chekifuserexists")
            }
            let user = self?.pullUserFromFirebase(snapshot)
            RequestPageViewController.userName = user
            self?.listenForRequest()
            self?.listenForRequestDeleted()
            self?.requestPage.rideRequestList.reloadData()
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
            self?.ref.child("Users").child(firebaseID).setValue(user.keyValues)
            RequestPageViewController.userName = user
            self?.listenForRequest()
            self?.listenForRequestDeleted()
            self?.requestPage.rideRequestList.reloadData()
        }
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

            RequestPageViewController.userName?.keyValues["Collage URL"] = url
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
            removeRequestInList(ride.unique!)
            LoadRequests.gRef.child("Requests").child(ride.unique!).removeValue()
            LoadRequests.gRef.child("Requests by Users/\((ride.rider?.unique)!)/Requests/\(ride.unique!)").removeValue()
            print(LoadRequests.requestList.count)
            
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
        
        var rider = User(url: URL(string: "http://i.imgur.com/CO5oZG1.jpg")!, name: "Booker T Washington")
        rider.keyValues["Profile Pic URL"] = "http://i.imgur.com/CO5oZG1.jpg"
        rider.phone = "512 686-7920"
        rider.keyValues["Name"] = rider.name
        var request = RideRequest(rider: rider)
        request.text = "Pickup domain to riveride"
        request.keyValues["Text"] = "Pickup domain to riveride"
        request.date = date
        request.keyValues["Date"] = "07-07-2017 10:08:13 am"
        request.ETA = "ETA: 9 min"
        request.state = RideRequest.State.resolved
        request.keyValues["State"] = "#Resolved"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/ezZRRss.jpg")!, name: "Donald J Trump")
        rider.keyValues["Profile Pic URL"] = "http://i.imgur.com/ezZRRss.jpg"
        rider.phone = "512 686-7920"
        rider.keyValues["Name"] = rider.name
        request = RideRequest(rider: rider)
        request.text = "Airport to Capitol please"
        request.keyValues["Text"] = "Airport to Capitol please"
        request.date = date
        request.keyValues["Date"] = "07-07-2017 10:08:13 am"
        request.ETA = "ETA: 9 min"
        request.state = RideRequest.State.canceled
        request.keyValues["State"] = "#Canceled"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/1jP1Zwv.jpg")!, name: "Wolverine")
        rider.keyValues["Profile Pic URL"] = "http://i.imgur.com/1jP1Zwv.jpg"
        rider.phone = "512 686-7920"
        rider.keyValues["Name"] = rider.name
        request = RideRequest(rider: rider)
        request.text = "Hey guys I have a favor to ask. I don't know if this is the right place but is it possible for someone to pick up my dog from my apartment and bring him to the vet? I'm so worried about him please help!"
        request.keyValues["Text"] = "Hey guys I have a favor to ask. I don't know if this is the right place but is it possible for someone to pick up my dog from my apartment and bring him to the vet? I'm so worried about him please help!"
        request.date = date
        request.keyValues["Date"] = "07-07-2017 10:08:13 am"
        request.ETA = "ETA: 9 min"
        request.state = RideRequest.State.resolved
        request.keyValues["State"] = "#Resolved"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/9QBGS2m.jpg")!, name: "Gregory Fenves")
        rider.keyValues["Profile Pic URL"] = "http://i.imgur.com/9QBGS2m.jpg"
        rider.phone = "512 686-7920"
        rider.keyValues["Name"] = rider.name
        request = RideRequest(rider: rider)
        request.text = "Redbud to UT asap"
        request.keyValues["Text"] = "Redbud to UT asap"
        request.date = date
        request.keyValues["Date"] = "07-07-2017 10:08:13 am"
        request.ETA = "ETA: 9 min"
        request.keyValues["State"] = "Unresolved"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/nnCNDRO.jpg")!, name: "Doggy")
        rider.keyValues["Profile Pic URL"] = "http://i.imgur.com/nnCNDRO.jpg"
        rider.phone = "512 686-7920"
        rider.keyValues["Name"] = rider.name
        request = RideRequest(rider: rider)
        request.text = "Hyde Park to Zilker"
        request.keyValues["Text"] = "Hyde Park to Zilker"
        request.date = date
        request.keyValues["Date"] = "07-07-2017 10:08:13 am"
        request.ETA = "ETA: 9 min"
        request.state = RideRequest.State.resolved
        request.keyValues["State"] = "#Resolved"
        LoadRequests.requestList.append(request)
    }

    
}
