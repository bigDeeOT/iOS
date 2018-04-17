//
//  MessagingViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/8/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class MessagingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessagesDelegate, UITextViewDelegate, UIScrollViewDelegate {
    var backend: MessagingBackend!
    var myMessage = "myMessage"
    var theirMessage = "theirMessage"
    var otherUser: User!
    @IBOutlet weak var send: UIImageView!
    @IBOutlet weak var type: UITextView!
    @IBOutlet weak var tableView: UITableView!
    var preSelectedMessage: String?
    var viewTranslation: CGFloat?
    @IBOutlet weak var stackView: UIStackView!
    var viewTransform: CGAffineTransform?
    var viewRecentFrame: CGRect?
    var typeOriginalFrame: CGRect?
    var typeRecentFrame: CGRect?
    var tableViewOriginalFrame: CGRect?
    var tableViewRecentFrame: CGRect?
    var lastIndexRowTableRefreshed = 0
    
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
        //testing()
    }
    
    private func testing() {
        let press = UIView()
        press.frame.size = CGSize(width: 50, height: 50)
        press.center = view.center
        press.backgroundColor = UIColor.red
        press.alpha = 0.5
        press.layer.cornerRadius = 25
        press.clipsToBounds = true
        press.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getPage)))
        press.isUserInteractionEnabled = true
        view.addSubview(press)
    }
    
    func getPage() {
        backend.getPageOfMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewRecentFrame = view.frame
        if typeOriginalFrame == nil {typeOriginalFrame = type.frame}
        setupRemoveKeyboardGesture()
        LoadRequests.clearMessagesNotification()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChangedSize), name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enteringForeground), name: .UIApplicationWillEnterForeground, object: nil)
        if let msg = preSelectedMessage {
            type.text = msg
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textViewDidChange(type)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        backend.ref?.child("Conversations/\((backend.conversationID)!)").removeAllObservers()
        type.endEditing(true)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let font = textView.font else {return}
        guard textView.text.isEmpty == false else {return}
        if tableViewOriginalFrame == nil {tableViewOriginalFrame = tableView.frame}
        let lines = Int((textView.contentSize.height - textView.textContainerInset.top - textView.textContainerInset.bottom) / font.lineHeight)
        guard lines <= 10 else {return}
        let displacement = (CGFloat(lines) - 1) * font.lineHeight
        type.frame.size.height = typeOriginalFrame!.size.height + displacement
        type.frame.origin.y = typeOriginalFrame!.origin.y - displacement
        tableView.frame.size.height = tableViewOriginalFrame!.size.height - displacement
        typeRecentFrame = type.frame
        tableViewRecentFrame = tableView.frame
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
        if tableViewRecentFrame != nil {tableView.frame = tableViewRecentFrame!}
        if typeRecentFrame != nil {type.frame = typeRecentFrame!}
    }
    
    func swipeDownToRemoveKeyboard() {
        type.endEditing(true)
    }

    func sendMessage() {
        guard type.text != nil else {return}
        backend.addMessage(type.text)
        type.frame = typeOriginalFrame!
        if tableViewOriginalFrame == nil {tableViewOriginalFrame = tableView.frame}
        tableView.frame = tableViewOriginalFrame!
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row != lastIndexRowTableRefreshed else {return}
        if indexPath.row == backend.messages.count - 1 {
            lastIndexRowTableRefreshed = indexPath.row
            backend.getPageOfMessages()
        }
    }
    
    func doneLoadingMessages() {
        tableView.reloadData()
    }
    
}
