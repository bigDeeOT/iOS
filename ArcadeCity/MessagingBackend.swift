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
    var lastMessageID: String?
    var pageSize: UInt = 40
    let ref = LoadRequests.gRef
    var messages = [Message]()
    var conversationID: String!
    var user1: String!
    var user2: String!
    var messagesDelegate: MessagesDelegate?
    
    //init sets the conversationID then gets the messages for said conversation
    init(_ user1: String, _ user2: String) {
        ref?.child("User Conversations/\(user1)/\(user2)").observeSingleEvent(of: .value, with: { [weak self] (snap) in
            self?.user1 = user1;
            self?.user2 = user2;
            if snap.exists() ==  false {
                self?.conversationID = self?.ref?.child("User Conversations/\(user1)/\(user2)").childByAutoId().key
                self?.ref?.child("User Conversations/\(user1)/\(user2)/").setValue(self?.conversationID!)
                self?.ref?.child("User Conversations/\(user2)/\(user1)/").setValue(self?.conversationID!)
            } else {
                self?.conversationID = snap.value as? String
            }
            self?.listenForNewMessages()
        })
    }
    
    private func listenForNewMessages() {
        ref?.child("Conversations/\(conversationID!)").queryLimited(toLast: 1).observe(.childAdded, with: { [weak self] (snapShot) in
            guard snapShot.exists() == true else {return}
            let messageInfo = snapShot.value as! [String:Any]
            self?.constructMessage(messageInfo, unique: snapShot.key, isNew: true)
            self?.ref?.child("Conversation Meta Data/\((self?.conversationID)!)/\((self?.user1)!)").setValue("Read")
            if self?.lastMessageID == nil {
                self?.lastMessageID = snapShot.key
                self?.getPageOfMessages()
            } else {
                self?.messagesDelegate?.doneLoadingMessages()
            }
        })
    }
    
    func getPageOfMessages() {
        ref?.child("Conversations/\(conversationID!)").queryOrderedByKey().queryLimited(toLast: pageSize).queryEnding(atValue: lastMessageID!).observeSingleEvent(of: .value, with: { [weak self] (snapShot) in
            guard snapShot.exists() else {return}
            for child in snapShot.children.reversed() {
                let unique = (child as! DataSnapshot).key
                let msgInfo = (child as! DataSnapshot).value as! [String : Any]
                guard unique != self?.lastMessageID else {continue}
                if unique < (self?.lastMessageID)! {self?.lastMessageID = unique}
                self?.constructMessage(msgInfo, unique: unique, isNew: false)
            }
            self?.messagesDelegate?.doneLoadingMessages()
        })
    }
    
    private func constructMessage(_ messageInfo: [String:Any], unique: String, isNew: Bool) {
        let message = Message()
        message.date = messageInfo["Date"] as? String
        message.string = messageInfo["String"] as? String
        message.user = messageInfo["User"] as? String
        message.unique = unique
        if true {
            let order = messageOrder(message.date!)
            ref?.child("Conversations/\(conversationID!)/\(message.unique!)/Order").setValue(order)
        }
        if (messages.count != 0) && (message.unique == messages[messages.count - 1].unique) {return}
        if isNew {
            messages.append(message)
        } else {
            messages.insert(message, at: 0)
        }
    }
    
    private func messageOrder(_ dateTxt: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
        let messageDate = dateFormatter.date(from: dateTxt)
        let time = messageDate?.timeIntervalSince1970
        return Int(-time!)
    }
    
    func addMessage(_ string: String) {
        guard string != "" else {return}
        let message = Message()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
        message.date = dateFormatter.string(from: Date())
        message.string = string
        message.user = user1;       //RequestPageViewController.userName?.unique
        messages.append(message)
        message.unique = ref?.child("Conversations/\(conversationID!)").childByAutoId().key
        let messageDetails = [
            "String"    : string,
            "Date"      : message.date!,
            "User"      : message.user!,
            "Order"     : messageOrder(message.date!)
            ] as [String : Any]
        ref?.child("Conversations/\(conversationID!)/\(message.unique!)").setValue(messageDetails)
        var metaDataDetails: [String:String]
        if user1 != user2 {
            metaDataDetails = [
                "Last Message"  : string,
                "Date"          : message.date!,
                user1           : "Read",
                user2           : "Unread"
            ]
        } else {
            metaDataDetails = [
                "Last Message"  : string,
                "Date"          : message.date!,
                user1           : "Read",
            ]
        }
        ref?.child("Conversation Meta Data/\(conversationID!)").setValue(metaDataDetails)
    }
    
}
