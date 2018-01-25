//
//  ConversationTableViewCell.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 1/21/18.
//  Copyright © 2018 The University of Texas at Austin. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var name: UILabel!
    var convoPage: ConversationsViewController?
    var conversation: Conversation!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            convoPage?.performSegue(withIdentifier: "goToChat", sender: conversation.otherUser)
        }
        message.lineBreakMode = .byWordWrapping
        message.numberOfLines = 0
        date.text = TimeAgo.get(conversation.date)
        message.text = conversation.lastMessage
        name.text = conversation.name
        loadPicture()
        clickToGoToUserProfile()
    }
    
    private func clickToGoToUserProfile() {
        picture.isUserInteractionEnabled = true
        picture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToUserProfile)))
    }
    
    func goToUserProfile() {
        convoPage?.performSegue(withIdentifier: "goToUserProfile", sender: conversation.otherUser)
    }
    
    func loadPicture() {
        if let pic = convoPage?.profilePicsCache[conversation.otherUserID] {
            picture.image = pic
            return
        }
        picture.image = #imageLiteral(resourceName: "profilePicPlaceHolder")
        if let url = URL(string: conversation.profilePicURL) {
            DispatchQueue.global(qos: .default).async {
                [weak self] in
                if let imageData = NSData(contentsOf: url) {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData as Data)
                        self?.picture.image = image
                        self?.convoPage?.profilePicsCache[(self?.conversation.otherUserID)!] = image
                        self?.picture.layer.cornerRadius = 4
                        self?.picture.layer.masksToBounds = true
                    }
                }
            }
        }
    }

}
