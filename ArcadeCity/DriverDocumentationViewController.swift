//
//  DriverDocumentationViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/20/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class DriverDocumentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!
    var backend = DriverDocumentationBackend()
    var documentsAreForEditing = true
    var cellToDismissKeybaord: TextDocumentTableViewCell?
    var tableViewDefaultInset: UIEdgeInsets?
    var datePickerCache: [UIDatePicker?] = []
    var picturesCache: [Int: UIImage] = [:]
    var submitButton: UIButton!
    var user: User?
    @IBOutlet weak var headerText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user == nil { user = RequestPageViewController.userName }
        tableView.dataSource = self
        tableView.delegate = self
        backend.user = user
        backend.controller = self
        backend.pullDocs()
        if documentsAreForEditing == true { attachFooter() }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        tableViewDefaultInset = UIEdgeInsetsMake(0, 0, tabBarController!.tabBar.frame.height, 0)
        tableView.contentInset = tableViewDefaultInset!
        if user?.info["Class"] != "Rider" {
            headerText.isHidden = true
        }
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
    }
    
    func loadDatePickers() {
        for _ in backend.documents {
            datePickerCache.append(UIDatePicker())
        }
    }
    
    func dismissKeyboard() {
        cellToDismissKeybaord?.textField.endEditing(true)
    }
    
    private func attachFooter() {
        let footer = UITableViewHeaderFooterView()
        let button = UIButton()
        //button.setTitle("Submit Documents", for: .normal)
        var buttonText = "Submit Documents"
        if (user?.info["Class"] == "Driver") || (user?.info["Class"] == "Pending Driver") {
            buttonText = "Update Documents"
        }
        let text = NSMutableAttributedString(string: buttonText, attributes: [
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15),
            NSForegroundColorAttributeName : UIColor.white,
            ])
        button.setAttributedTitle(text, for: .normal)
        button.sizeToFit()
        button.frame.size.width = button.frame.size.width + 50
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.red
        button.frame.origin.x = (UIScreen.main.bounds.width - button.frame.size.width) / 2
        button.frame.origin.y = 35
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(submit)))
        button.isUserInteractionEnabled = true
        submitButton = button
        footer.addSubview(button)
        tableView.tableFooterView = footer
        tableView.tableFooterView?.frame.size.width = UIScreen.main.bounds.width
        tableView.tableFooterView?.frame.size.height = button.frame.height + 35
    }
    
    func submit() {
        if user?.info["Class"] != "Driver" {
            saveDocuments()
        } else {
            submitOptions()
        }
    }
    
    func submitOptions() {
        let actionSheet = UIAlertController(title: "Submitting Documents will change your class from Driver to Pending Driver", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.saveDocuments()
        }
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(okAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func saveDocuments() {
        backend.saveDocuments()
        let text = NSMutableAttributedString(string: "Submitted!", attributes: [
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15),
            NSForegroundColorAttributeName : UIColor.black,
            ])
        submitButton.setAttributedTitle(text, for: .normal)
        submitButton.isUserInteractionEnabled = false
        submitButton.backgroundColor = UIColor(red:0.54, green:0.85, blue:0.98, alpha:1.0)
        if (user!.info["Class"] != "Moderator") && (user!.info["Class"] != "Admin") {
            LoadRequests.gRef.child("\(user!.info["Class"] ?? "")s/\(user!.unique ?? "")").removeValue()
            user!.info["Class"] = "Pending Driver"
            LoadRequests.updateUser(user: user!)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return backend.documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let document = backend.documents[indexPath.row]
        let cellType = document.type
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType!, for: indexPath)
        if let cell = cell as? TextDocumentTableViewCell {
            cell.controller = self
            cell.indexPath = indexPath
            cell.document = document
        } else if let cell = cell as? DateDocumentTableViewCell {
            cell.controller = self
            cell.indexPath = indexPath
            cell.document = document
        } else if let cell = cell as? PictureDocumentTableViewCell {
            cell.controller = self
            cell.indexPath = indexPath
            cell.document = document
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if backend.documents[indexPath.row].type == "Picture" {
            return 280
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ImageViewController {
            vc.image = sender as? UIImageView
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(red:0.16, green:0.46, blue:0.75, alpha:1.0)
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
        ]
        navigationItem.title = "Required Documents"
    }

}
