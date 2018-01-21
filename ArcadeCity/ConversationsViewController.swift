//
//  ConversationsViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 1/20/18.
//  Copyright © 2018 The University of Texas at Austin. All rights reserved.
//

import UIKit

class ConversationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let backend = ConversationBackend()
    override func viewDidLoad() {
        super.viewDidLoad()
        backend.pullConversations()
    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return backend.conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
