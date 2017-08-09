//
//  MessagingBackend.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/8/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation
import Firebase

class MessagingBackend {
    let ref = LoadRequests.gRef
    var messages = [Message]()
    var conversationID: String!
    var messagesDelegate: MessagingViewController?
    
    //init sets the conversationID then gets the messages for said conversation
    init(_ user1: String, _ user2: String) {
        ref?.child("User Conversations/\(user1)/\(user2)").observeSingleEvent(of: .value, with: { (snap) in
            if snap.exists() ==  false {
                self.conversationID = self.ref?.child("User Conversations/\(user1)/\(user2)").childByAutoId().key
                self.ref?.child("User Conversations/\(user2)/\(user1)").setValue(self.conversationID)
            } else {
                self.conversationID = snap.value as? String
            }
            //Now get all the messages
            self.ref?.child("Conversations/\(self.conversationID)").observe(.childAdded, with: { (snap) in
                self.pullMessages(snap)
                //messagesDelegate.doneLoadingMessages()
            })
        })
    }
    
    private func pullMessages(_ snap: DataSnapshot) {
        guard snap.exists() == true else {
            return
        }
        let messageInfo = snap.value as! [String:String]
        let message = Message()
        message.date = messageInfo["Date"]
        message.string = messageInfo["String"]
        message.user = messageInfo["User"]
        message.unique = snap.key
        messages.append(message)
    }
    
    private func addMessage(_ string: String) {
        let message = Message()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
        message.date = dateFormatter.string(from: Date())
        message.string = string
        message.user = RequestPageViewController.userName?.unique
        messages.append(message)
        message.unique = ref?.child("Conversations/\(conversationID)").childByAutoId().key
        ref?.child("Conversations/\(conversationID)/\(message.unique!)").child("String").setValue(string)
        ref?.child("Conversations/\(conversationID)/\(message.unique!)").child("String").setValue(message.date)
        ref?.child("Conversations/\(conversationID)/\(message.unique!)").child("String").setValue(message.user)
    }
    
    
}
