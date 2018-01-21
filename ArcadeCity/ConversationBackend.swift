//
//  ConversationBackend.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 1/19/18.
//  Copyright © 2018 The University of Texas at Austin. All rights reserved.
//

import Foundation
import Firebase

protocol ConversationsDelegate {
    func doneLoadingConversations()
}

class ConversationBackend {
    var user: User!
    var ref = LoadRequests.gRef
    var conversations = [Conversation]()
    var conversationsDelegate: ConversationsDelegate?
    
    func pullConversations() {
        let conversation = Conversation()
        ref?.child("User Conversations/\(user.unique!)").observe(.childAdded, with: { [weak self] (snapShot) in
            guard snapShot.exists() else {return}
            conversation.ID = snapShot.value as! String
            conversation.otherUserID = snapShot.key
            self?.ref?.child("Users/\(conversation.otherUserID)").observeSingleEvent(of: .value, with: { (snapShot1) in
                guard snapShot1.exists() else {return}
                let userInfo = snapShot1.value as! [String:String]
                conversation.name = userInfo["Name"]!
                conversation.profilePicURL = userInfo["Profile Pic URL"]!
                self?.ref?.child("Conversation Meta Data/\(conversation.ID)").observeSingleEvent(of: .value, with: { (snapShot2) in
                    guard snapShot2.exists() else {return}
                    var metaData = snapShot2.value as! [String:String]
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
                    conversation.date = dateFormatter.date(from: metaData["Date"]!)
                    conversation.lastMessage = metaData["Last Message"]!
                    conversation.read = metaData[(self?.user.unique)!]! == "Read" ? true : false
                    self?.conversations.append(conversation)
                })
            })
        })
    }
}
