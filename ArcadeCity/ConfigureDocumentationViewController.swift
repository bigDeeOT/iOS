//
//  ConfigureDocumentationViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/19/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class ConfigureDocumentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var buttonColor = UIColor(red:0.01, green:0.40, blue:0.76, alpha:1.0)
    @IBOutlet weak var edit: UIButton!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var backend = ConfigureDocsBackend()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        backend.pullRequirements()
        backend.controller = self
        styleButtons()
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
    
    private func styleButtons() {
        add.layer.backgroundColor = buttonColor.cgColor
        add.setTitleColor(UIColor.white, for: .normal)
        edit.layer.backgroundColor = buttonColor.cgColor
        edit.setTitleColor(UIColor.white, for: .normal)
        add.layer.cornerRadius = add.frame.size.height / 2
        edit.layer.cornerRadius = edit.frame.size.height / 2
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        guard tableView.isEditing == false else {return}
        performSegue(withIdentifier: "addDocument", sender: nil)
    }
    
    @IBAction func editAction(_ sender: UIButton) {
        if tableView.isEditing == false {
            tableView.setEditing(true, animated: true)
            edit.layer.backgroundColor = UIColor.red.cgColor
        } else {
            tableView.setEditing(false, animated: true)
            edit.layer.backgroundColor = buttonColor.cgColor
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return backend.documents.count
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let title = backend.documents[sourceIndexPath.row].title
        backend.changeRequirementIndex(title: title!, fromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let document = backend.documents[indexPath.row]
            backend.removeRequirement(document: document)
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "document", for: indexPath)
        let document = backend.documents[indexPath.row]
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = document.title
        cell.detailTextLabel?.text = document.type!
        cell.showsReorderControl = true //need this?
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddDriverDocViewController {
            vc.controller = self
        }
    }
    
    @IBAction func rewindToConfigureDocs(segue: UIStoryboardSegue) {
    }
    
}
