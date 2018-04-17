//
//  ConversationsViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 1/20/18.
//  Copyright © 2018 The University of Texas at Austin. All rights reserved.
//

import UIKit

class ConversationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ConversationsDelegate {
    
    let backend = ConversationBackend()
    var profilePicsCache: [String: UIImage] = [:]
    @IBOutlet weak var convoTable: UITableView!
    var navBarColor = UIColor(red:0.16, green:0.46, blue:0.75, alpha:1.0)
    var maxConversationsLoaded = 0
    var conversationsLoaded = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backend.user = RequestPageViewController.userName
        backend.conversationsDelegate = self
        convoTable.dataSource = self
        convoTable.delegate = self
        convoTable.rowHeight = 75
        self.title = "Messages"
        navigationBarStyle()
        convoTable.allowsSelection = true
        convoTable.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
        LoadRequests.clearMessagesNotification()
        refreshConversationList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func navigationBarStyle() {
        let navBar = navigationController?.navigationBar
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        navBar?.barTintColor = navBarColor
        navBar?.tintColor = UIColor.white
        navBar?.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold)
        ]
        navBar?.setValue(true, forKey: "hidesShadow")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return backend.conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "convoCell", for: indexPath) as! ConversationTableViewCell
        cell.conversation = backend.conversations[indexPath.row]
        cell.convoPage = self
        cell.selectionStyle = .none
        return cell
    }

    func newConversationAvailable() {
        conversationsLoaded += 1
        if conversationsLoaded > maxConversationsLoaded {
            maxConversationsLoaded = conversationsLoaded
        }
        if conversationsLoaded == maxConversationsLoaded {
            convoTable.reloadData()
        }
    }

    func refreshConversationList() {
        guard conversationsLoaded == maxConversationsLoaded else {return}
        conversationsLoaded = 0
        backend.conversations.removeAll()
        backend.pullConversations()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProfileViewController {
            vc.user = sender as? User
        }
        if let vc = segue.destination as? MessagingViewController {
            vc.otherUser = sender as? User
        }
    }
    
}
