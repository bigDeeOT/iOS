//
//  MessagingViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/8/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class MessagingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessagesDelegate, UITextViewDelegate, UIScrollViewDelegate {
    var myMessage = "myMessage"
    var theirMessage = "theirMessage"
    var otherUser: User!
    @IBOutlet weak var send: UIImageView!
    @IBOutlet weak var type: UITextView!
    @IBOutlet weak var tableView: UITableView!
    var backend: MessagingBackend!
    var preSelectedMessage: String?
    var viewTranslation: CGFloat?
    @IBOutlet weak var stackView: UIStackView!
    var viewTransform: CGAffineTransform?
    var viewRecentFrame: CGRect?
    var typeOriginalFrame: CGRect?
    var tableViewOriginalFrame: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        backend = MessagingBackend((RequestPageViewController.userName?.unique)!, otherUser.unique!)
        backend.messagesDelegate = self
        type.layer.cornerRadius = 10
        type.layer.borderColor = UIColor.lightGray.cgColor
        type.layer.borderWidth = 1
        type.delegate = self
        viewRecentFrame = view.frame
        typeOriginalFrame = type.frame
        tableViewOriginalFrame = tableView.frame
        if let msg = preSelectedMessage {
            type.text = msg
        }
        send.isUserInteractionEnabled = true
        send.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendMessage)))
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 30
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat).pi)
        navigationItem.title = otherUser.info["Name"]
        view.window?.backgroundColor = UIColor.white
    }
    
    func textViewDidChange(_ textView: UITextView) {
        return
        guard let font = textView.font else {return}
        let lines = Int((textView.contentSize.height - textView.textContainerInset.top - textView.textContainerInset.bottom) / font.lineHeight)
        let displacement = (CGFloat(lines) - 1) * font.lineHeight
        type.frame.size.height = typeOriginalFrame!.size.height + displacement
        tableView.frame.size.height = tableViewOriginalFrame!.size.height - displacement
    }
    
    func keyboardChangedSize(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        guard let tabBarHeight = tabBarController?.tabBar.frame.height else {return}
        let keyboardIsUp = keyboardFrame.origin.y < UIScreen.main.bounds.height
        viewTranslation = keyboardFrame.height - tabBarHeight
        if keyboardIsUp {
            view.transform = CGAffineTransform(translationX: 0, y: -viewTranslation!)
        } else {
            view.transform = .identity
        }
        viewRecentFrame = view.frame
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == type as UIScrollView else {return}
        if scrollView.panGestureRecognizer.translation(in: scrollView).y > 0 {
            type.endEditing(true)
        }
    }
    
    private func setupRemoveKeyboardGesture() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownToRemoveKeyboard))
        swipe.direction = .down
        swipe.numberOfTouchesRequired = 1
        type.addGestureRecognizer(swipe)
    }
    
    func enteringForeground() {
        view.frame = viewRecentFrame!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupRemoveKeyboardGesture()
        LoadRequests.clearMessagesNotification()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChangedSize), name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enteringForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        backend.ref?.child("Conversations/\((backend.conversationID)!)").removeAllObservers()
        type.endEditing(true)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    func swipeDownToRemoveKeyboard() {
        type.endEditing(true)
    }

    func sendMessage() {
        guard type.text != nil else {return}
        backend.addMessage(type.text)
        type.text = ""
        type.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return backend.messages.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        let message = backend.messages[backend.messages.count - 1 - indexPath.row]
        if message.user == RequestPageViewController.userName?.unique {
            cell = tableView.dequeueReusableCell(withIdentifier: myMessage, for: indexPath)
            if let cell = cell as? MyMessageTableViewCell {
                cell.message = message
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: theirMessage, for: indexPath) as! TheirMessageTableViewCell
            if let cell = cell as? TheirMessageTableViewCell {
                cell.message = message
            }
        }
        cell.transform = CGAffineTransform(rotationAngle: (CGFloat).pi)
        return cell
    }
    
    func doneLoadingMessages() {
        tableView.reloadData()
    }
    
}
