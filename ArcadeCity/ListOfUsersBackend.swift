//
//  ListOfUsersBackend.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/15/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation
import Firebase

class ListOfUsersBackend {
    var controller: ListOfUsersViewController?
    var users: [User] = []
    var pageBoundary = ""
    var pageSize: UInt = 20
    var group = "Users"
    var loadedAllUsers = false
    
    init() {
        loadList()
    }
    
    /*
    func loadList() {
        LoadRequests.gRef.child(group).queryOrderedByKey().queryLimited(toLast: pageSize).observeSingleEvent(of: .value, with: { (snap) in
            guard snap.exists() else {self.controller?.tableViewUsers.reloadData();return}
            self.createUsers(from: snap)
        })
    }
 */
    
    func loadList() {
        LoadRequests.gRef.child(group).queryOrdered(byChild: "Name").queryLimited(toLast: pageSize).observeSingleEvent(of: .value, with: { (snap) in
            guard snap.exists() else {self.controller?.tableViewUsers.reloadData();return}
            self.createUsers(from: snap)
        })
    }
    
    func loadMore() {
        guard pageBoundary != "" else {return}
        guard loadedAllUsers == false else {return}
        LoadRequests.gRef.child(group).queryOrderedByKey().queryEnding(atValue: pageBoundary).queryLimited(toLast: pageSize).observeSingleEvent(of: .value, with: { (snap) in
            guard snap.exists() else {return}
            guard snap.children.allObjects.count > 1 else {self.loadedAllUsers = true; return}
            self.createUsers(from: snap)
        })
    }
    
    func createUsers(from userList: DataSnapshot) {
        let duplicate = pageBoundary
        for child in userList.children {
            let key = (child as! DataSnapshot).key
            let userDetails = (child as! DataSnapshot).value as! [String:String]
            if (key < pageBoundary) || (pageBoundary == "") {pageBoundary = key}
            guard key != duplicate else {continue}
            let user = User(userDetails)
            user.unique = key
            users.append(user)
        }
        controller?.tableViewUsers.reloadData()
    }
    
    func clear() {
        users.removeAll()
    }
}
