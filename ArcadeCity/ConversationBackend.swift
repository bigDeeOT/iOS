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
    func newConversationAvailable()
}

class ConversationBackend {
    var user: User!
    lazy var ref = LoadRequests.gRef
    var conversations = [Conversation]()
    var conversationsDelegate: ConversationsDelegate?
    
    func pullConversations() {
        ref?.child("User Conversations/\(user.unique!)").observe(.childAdded, with: { [weak self] (snapShot) in
            guard snapShot.exists() else {return}
            let conversation = Conversation()
            conversation.ID = snapShot.value as! String
            conversation.otherUserID = snapShot.key
            self?.ref?.child("Users/\(conversation.otherUserID!)").observeSingleEvent(of: .value, with: { (snapShot1) in
                guard snapShot1.exists() else {return}
                let userInfo = snapShot1.value as! [String:String]
                conversation.otherUser = User(userInfo)
                conversation.name = userInfo["Name"]!
                conversation.profilePicURL = userInfo["Profile Pic URL"]!
                self?.ref?.child("Conversation Meta Data/\(conversation.ID!)").observeSingleEvent(of: .value, with: { (snapShot2) in
                    guard snapShot2.exists() else {return}
                    var metaData = snapShot2.value as! [String:String]
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
                    conversation.date = dateFormatter.date(from: metaData["Date"]!)
                    conversation.lastMessage = metaData["Last Message"]!
                    if let readStatus = metaData[(self?.user.unique)!] {
                        conversation.read = (readStatus == "Read")
                    } else {conversation.read = true}
                    self?.conversations.append(conversation)
                    self?.conversations.sort(by: { (convo1, convo2) -> Bool in
                        let date1 = -Int(convo1.date.timeIntervalSinceNow)
                        let date2 = -Int(convo2.date.timeIntervalSinceNow)
                        return date1 < date2
                    })
                    self?.conversationsDelegate?.newConversationAvailable()
                })
            })
        })
    }
}
