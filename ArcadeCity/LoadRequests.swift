//
//  LoadRequests.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/14/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit

class LoadRequests {
    var ref: DatabaseReference!
    static var gRef: DatabaseReference!
    static var requestList = [RideRequest]()
    static var needToLoad = true
    var userInfo: [String:String] = [:]
    var waitingPage: WaitingForDatabaseViewController!
    var requestPage: RequestPageViewController!
    
    init() {
        if LoadRequests.needToLoad {
       loadRequestsFullOfJunk()
            LoadRequests.needToLoad = false
        }
        ref = Database.database().reference()
        LoadRequests.gRef = ref
    }
    
    func get() -> [RideRequest] {
        return LoadRequests.requestList
    }
    
    static func addRequestToList(_ request: RideRequest){
        if LoadRequests.requestList.count >= 100 {
            LoadRequests.requestList.removeFirst(3)
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
    
    func listenForRequest() {
        self.ref.child("Requests").observe(.childAdded, with: { [weak self] (snapshot) in
            let unique = snapshot.key
            guard LoadRequests.requestList.last?.unique != unique else { return }
            let details = snapshot.value as! [String:Any]
            let request = RideRequest()
            request.text = details["Text"] as? String
            if details["Show ETA"] as! String == "True" {
                request.showETA = true } else { request.showETA = false }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
            let date = dateFormatter.date(from: details["Date"] as! String)
            request.date = date
            let riderUnique = details["Rider"] as! String
            self?.ref.child("Users/\(riderUnique)").observeSingleEvent(of: .value, with: { [weak self] (snapShotUser) in
                guard snapShotUser.exists() else {return}
                let user = self?.pullUserFromFirebase(snapShotUser)
                request.rider = user
                self?.requestPage.rideRequestList.reloadData()
            })
            LoadRequests.addRequestToList(request)
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
                self?.waitingPage?.go()
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
        guard let firebaseID = Auth.auth().currentUser?.uid else {return}
        self.ref.child("Users").child(firebaseID).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard snapshot.exists() else {
                print("user does not exist")
                self?.createNewUserInFirebase(firebaseID)
                return
            }
            let user = self?.pullUserFromFirebase(snapshot)
            RequestPageViewController.userName = user
            self?.requestPage.rideRequestList.reloadData()
            self?.waitingPage?.go()
        })
    }
    
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
 
    private func createNewUserInFirebase(_ firebaseID: String) {
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start {[weak self] (connection, result, err) in
            if err != nil {
                print("failed to print out graph request", err ?? "")
                return
            }
            print("result from getFBname", result ?? "")
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
            self?.requestPage.rideRequestList.reloadData()
            self?.waitingPage?.go()
        }
    }
    
    private func loadRequestsFullOfJunk() {
        var rider = User(url: URL(string: "http://i.imgur.com/CO5oZG1.jpg")!, name: "Booker T Washington")
        rider.phone = "512 686-7920"
        var request = RideRequest(rider: rider)
        request.text = "Pickup domain to riveride"
        request.date = Date()
        request.ETA = "ETA: 9 min"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/ezZRRss.jpg")!, name: "Donald J Trump")
        rider.phone = "512 686-7920"
        request = RideRequest(rider: rider)
        request.text = "Airport to Capitol please"
        request.date = Date()
        request.ETA = "ETA: 9 min"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/1jP1Zwv.jpg")!, name: "Wolverine")
        rider.phone = "512 686-7920"
        request = RideRequest(rider: rider)
        request.text = "Hey guys I have a favor to ask. I don't know if this is the right place but is it possible for someone to pick up my dog from my apartment and bring him to the vet? I'm so worried about him please help!"
        request.date = Date()
        request.ETA = "ETA: 9 min"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/9QBGS2m.jpg")!, name: "Gregory Fenves")
        rider.phone = "512 686-7920"
        request = RideRequest(rider: rider)
        request.text = "Redbud to UT"
        request.date = Date()
        request.ETA = "ETA: 9 min"
        LoadRequests.requestList.append(request)
        
        rider = User(url: URL(string: "http://i.imgur.com/nnCNDRO.jpg")!, name: "Doggy")
        rider.phone = "512 686-7920"
        request = RideRequest(rider: rider)
        request.text = "Hyde Park to Zilker"
        request.date = Date()
        request.ETA = "ETA: 9 min"
        LoadRequests.requestList.append(request)
    }

    
}
