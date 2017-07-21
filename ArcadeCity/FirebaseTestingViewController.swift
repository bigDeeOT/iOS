//
//  FirebaseTestingViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/20/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit
import Firebase

class FirebaseTestingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myList: [String] = []
    var ref: DatabaseReference!
    var handle: DatabaseHandle?
    var ID: String?

    @IBOutlet weak var banner: UILabel!
    @IBOutlet weak var myTextField: UITextField!
    @IBOutlet weak var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        let id = initializeDatabase()
        handle = ref.child("Ride Requests").child(id).child("Offers").observe(.childAdded, with: { (snapshot) in
            guard let item = snapshot.key as? String else {return}
            self.myList.append(item)
            print("adding :", item)
            self.table.reloadData()
        })

    }
    
    func initializeDatabase() -> String {
        let id = ref.child("Ride Requests").childByAutoId().key
        ref.child("Ride Requests").child(id).setValue([
            "Rider"     : "user5",
            "Date"      : "day5",
            "location"  : "area5",
            "text"      : "dog park please",
            "showETA"   : "T",
            ])
        for i in 1..<5 {
            let key = ref.child("Offers").childByAutoId().key
            ref.child("Offers").child(key).setValue([
                "Driver"    : "Washington\(i)",
                "Date"      : "day \(5 + i)",
                "ETA"       : "\(4 + i) min",
                "comment"   : "hey man I got you",
                "Ride Request": id,
                ])
            ref.child("Ride Requests").child(id).child("Offers").child(key).setValue("T")
            ref.child("Drivers").child("By Ride Requests").child(id).child("Washington\(i)").setValue("T")
        }
        ID = id
        return id
    }
    
    @IBAction func saveBtn(_ sender: UIButton) {
        //saving item to database
        guard let text = myTextField.text else {return}
        ref.child("Drivers/By Ride Requests").child(ID!).child(text).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? String {
                self.banner.text = "Yes, that driver did offer a ride - \(value)"
            self.ref.child("Drivers/By Ride Requests").child(self.ID!).child(text).removeValue()
            } else {
                self.banner.text = "No"
            }
        })
        myTextField.text = ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = myList[indexPath.row]
        return cell
    }

}
