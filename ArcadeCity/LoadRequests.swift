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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let date = dateFormatter.string(from: request.date!)
        let autoID = LoadRequests.gRef.child("Requests").childByAutoId().key
        LoadRequests.gRef.child("Requests/\(autoID)").setValue([
            "Text"          : request.text,
            "Rider"         : request.rider?.unique,
            "Date"          : date,
            "Show ETA"      : request.showETA ? "True" : "False"
            ])
        LoadRequests.gRef.child("Requests by Users/\((request.rider?.unique)!)/Requests/\(autoID)").setValue("True")
        request.unique = autoID
    }
    
    static func addOffer(_ offer: Offer, for rideRequest: RideRequest) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
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
    
    
    
    func listenForOffer(_ request: RideRequest) {
        self.ref.child("Requests/\(request.unique!)/Offers").observe(.childAdded, with: { [weak self] (offerSnapshot) in
            let offerUnique = offerSnapshot.key
            self?.ref.child("Offers/\(offerUnique)").observeSingleEvent(of: .value, with: { (offerDetailSnapshot) in
                guard offerDetailSnapshot.exists() else { return }
                let offerDetails = offerDetailSnapshot.value as! [String:Any]
                let offer = Offer()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
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
            self?.requestPage.rideRequestList.reloadData()
        })
    }
    
    
    
    /*
    private func pullUserFromFirebase(_ snapshot: DataSnapshot) -> User {
        let userInfo = snapshot.value as! [String:Any]
        let picURL = userInfo["Profile Pic URL"] as? String
        let name = userInfo["Name"] as? String
        let privilege = userInfo["Privilege"] as? String
        let phone = userInfo["Phone"] as? String
        let user = User(url: picURL!, name: name!)
        user.phone = phone
        user.collage = URL(string: picURL!)
        user.unique = snapshot.key
        switch privilege! {
        case "driver":
            user.privilege = User.Privilege.driver
        case "mod":
            user.privilege = User.Privilege.moderator
        case "admin":
            user.privilege = User.Privilege.administrator
        case "banned":
            user.privilege = User.Privilege.banned
        default:
            break
        }
        return user
    }
    */
 /*
    private func createNewUserInFirebase(_ firebaseID: String) {
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start {[weak self] (connection, result, err) in
            if err != nil {
                print("failed to print out graph request", err ?? "")
                return
            }
            let fbInfo = result as! [String:String]
            let name = fbInfo["name"]
            let id = fbInfo["id"]
            let picURL = "http://graph.facebook.com/\(id!)/picture?type=normal"
            self?.ref.child("Users").child(firebaseID).setValue([
                "Name"              : name!,
                "Profile Pic URL"   : picURL,
                "Rides Requested"   : 0,
                "Rides Resolved"    : 0,
                "Rides Offered"     : 0,
                "Rides Given"       : 0,
                "Collage URL"       : "http://i.imgur.com/nnCNDRO.jpg",
                "Phone"             : "512-867-5309",
                "Privilege"         : "driver"
                ])
            let user = User(url: picURL, name: name!)
            user.phone = "512-867-5309"
            user.collage = URL(string: picURL)
            user.unique = firebaseID
            RequestPageViewController.userName = user
            self?.listenForRequest()
            self?.requestPage.rideRequestList.reloadData()
        }
    }
 */
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
        LoadRequests.gRef.child("Requests").child(ride.unique!).child("Offers").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let offers = snapshot.value as? [String:String]
                for (offer, _) in offers! {
                    LoadRequests.gRef.child("Offers").child(offer).removeValue()
                }
                LoadRequests.removeOfferListener(requestNumber: ride.unique!)
            }
            removeRequestInList(ride.unique!)
            LoadRequests.gRef.child("Requests").child((ride.unique)!).removeValue()
            print(LoadRequests.requestList.count)
            
            LoadRequests.rideDetailPage.performSegue(withIdentifier: "deleteRequest", sender: nil)
        })
    }
    
    static func removeRequestInList(_ unique: String) {
        for i in 0..<LoadRequests.requestList.count {
            print(LoadRequests.requestList[i].unique ?? "no request unique", "and ", unique )
            if LoadRequests.requestList[i].unique == unique {
                LoadRequests.requestList.remove(at: i)
                print("removed one")
                break
            }
        }
    }
    
    
    static private func loadRequestsFullOfJunk() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
        let date = dateFormatter.date(from: "07-07-2017 10:08:13 am")
        
        var rider = User(url: URL(string: "http://i.imgur.com/CO5oZG1.jpg")!, name: "Booker T Washington")
        rider.phone = "512 686-7920"
        var request = RideRequest(rider: rider)
        request.text = "Pickup domain to riveride"
        request.date = date
        request.ETA = "ETA: 9 min"
        request.state = RideRequest.State.resolved
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/ezZRRss.jpg")!, name: "Donald J Trump")
        rider.phone = "512 686-7920"
        request = RideRequest(rider: rider)
        request.text = "Airport to Capitol please"
        request.date = date
        request.ETA = "ETA: 9 min"
        request.state = RideRequest.State.canceled
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/1jP1Zwv.jpg")!, name: "Wolverine")
        rider.phone = "512 686-7920"
        request = RideRequest(rider: rider)
        request.text = "Hey guys I have a favor to ask. I don't know if this is the right place but is it possible for someone to pick up my dog from my apartment and bring him to the vet? I'm so worried about him please help!"
        request.date = date
        request.ETA = "ETA: 9 min"
        request.state = RideRequest.State.resolved
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/9QBGS2m.jpg")!, name: "Gregory Fenves")
        rider.phone = "512 686-7920"
        request = RideRequest(rider: rider)
        request.text = "Redbud to UT"
        request.date = date
        request.ETA = "ETA: 9 min"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/nnCNDRO.jpg")!, name: "Doggy")
        rider.phone = "512 686-7920"
        request = RideRequest(rider: rider)
        request.text = "Hyde Park to Zilker"
        request.date = date
        request.ETA = "ETA: 9 min"
        request.state = RideRequest.State.resolved
        LoadRequests.requestList.append(request)
    }

    
}
