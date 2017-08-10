//
//  MessagingBackend.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/8/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation
import Firebase

protocol MessagesDelegate {
    func doneLoadingMessages()
}

class MessagingBackend {
    let ref = LoadRequests.gRef
    var messages = [Message]()
    var conversationID: String!
    var messagesDelegate: MessagesDelegate?
    
    //init sets the conversationID then gets the messages for said conversation
    init(_ user1: String, _ user2: String) {
        ref?.child("User Conversations/\(user1)/\(user2)").observeSingleEvent(of: .value, with: { (snap) in
            if snap.exists() ==  false {
                self.conversationID = self.ref?.child("User Conversations/\(user1)/\(user2)").childByAutoId().key
                self.ref?.child("User Conversations/\(user1)/\(user2)/").setValue(self.conversationID!)
                self.ref?.child("User Conversations/\(user2)/\(user1)/").setValue(self.conversationID!)
            } else {
                self.conversationID = snap.value as? String
            }
            //Now get all the messages
            self.ref?.child("Conversations/\(self.conversationID!)").observe(.childAdded, with: { (snapShot) in
                self.pullMessages(snapShot)
                self.messagesDelegate?.doneLoadingMessages()
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
        if (messages.count != 0) && (message.unique == messages[messages.count - 1].unique) {return}
        messages.append(message)
    }
    
    func addMessage(_ string: String) {
        guard string != "" else {return}
        let message = Message()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
        message.date = dateFormatter.string(from: Date())
        message.string = string
        message.user = RequestPageViewController.userName?.unique
        messages.append(message)
        message.unique = ref?.child("Conversations/\(conversationID!)").childByAutoId().key
        /*
        ref?.child("Conversations/\(conversationID!)/\(message.unique!)").child("String").setValue(string)
        ref?.child("Conversations/\(conversationID!)/\(message.unique!)").child("Date").setValue(message.date)
        ref?.child("Conversations/\(conversationID!)/\(message.unique!)").child("User").setValue(message.user)
        */
        let messageDetails = [
            "String"    : string,
            "Date"      : message.date,
            "User"      : message.user
            ]
 
        ref?.child("Conversations/\(conversationID!)/\(message.unique!)").setValue(messageDetails)
        
        let metaDataDetails = [
            "Last Message"  : string,
            "Date"          : message.date
        ]
        /*
        ref?.child("Conversation Meta Data/\(conversationID!)/Last Message").setValue(string)
        ref?.child("Conversation Meta Data/\(conversationID!)/Date").setValue(message.date)
 */
        ref?.child("Conversation Meta Data/\(conversationID!)").setValue(metaDataDetails)
    }
    
}
