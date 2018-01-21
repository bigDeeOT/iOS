//
//  DriverDocumentationBackend.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/20/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class DriverDocumentationBackend {
    var documents: [Document] = []
    var controller: DriverDocumentationViewController?
    var docID: String?
    var user: User?
    
    func pullDocs() {
        pullRequirements()
    }
    
    private func pullRequirements() {
        LoadRequests.gRef.child("Documentation Configuration").queryOrdered(byChild: "Index").observeSingleEvent(of: .value, with: { (snap) in
            guard snap.exists() else {return}
            for child in snap.children {
                let title = (child as! DataSnapshot).key
                let type = ((child as! DataSnapshot).value as! [String:Any])["Type"] as! String
                let index = ((child as! DataSnapshot).value as! [String:Any])["Index"] as! Int
                let document = Document(title: title, type: type, index: index)
                self.documents.append(document)
            }
            self.pullDocValues()
        })
    }
    
    private func pullDocValues() {
        guard user?.info["Documentation"] != nil else {
            docID = LoadRequests.gRef.child("Users/\(user!.unique!)/Documentation").childByAutoId().key
            LoadRequests.gRef.child("Users/\(user!.unique!)/Documentation").setValue(docID!)
            LoadRequests.gRef.child("Documentation/\(docID!)").setValue("empty")
            self.controller?.loadDatePickers()
            self.controller?.tableView.reloadData()
            return
        }
        docID = user?.info["Documentation"]
        LoadRequests.gRef.child("Documentation/\(docID!)").observeSingleEvent(of: .value, with: { (snap) in
            guard let docInfo = snap.value as? [String:String] else {
                self.controller?.loadDatePickers()
                self.controller?.tableView.reloadData()
                return
            }
            for doc in self.documents {
                doc.value = docInfo[doc.title!]
                doc.valueToSave = docInfo[doc.title!]
            }
            self.controller?.loadDatePickers()
            self.controller?.tableView.reloadData()
        })
    }
    
    func saveDocuments() {
        for doc in documents {
            if doc.type == "Text"       { saveTextDoc(doc) }
            if doc.type == "Date"       { saveDateDoc(doc) }
            if doc.type == "Picture"    { savePictureDoc(doc) }
        }
    }
    
    private func saveTextDoc(_ doc: Document) {
        guard let text = doc.valueToSave else {return}
        LoadRequests.gRef.child("Documentation/\(docID!)/\(doc.title!)").setValue(text as! String)
    }
    
    private func saveDateDoc(_ doc: Document) {
        guard doc.valueToSave != nil else {return}
        saveTextDoc(doc)
    }
    
    private func savePictureDoc(_ doc: Document) {
        guard let picture = doc.valueToSave as? UIImage else {return}
        guard let uid = Auth.auth().currentUser?.uid else { print("can't get UID"); return }
        let refStore = Storage.storage().reference().child("\(uid)/Documentation/\(doc.title!).jpg")
        let imageData = UIImageJPEGRepresentation(picture, 0.1)
        refStore.putData(imageData!, metadata: nil) { (meta, err) in
            if err != nil { print("error uploading image data ", err!); return }
            let url = String(describing: (meta?.downloadURL())!)
            LoadRequests.gRef.child("Documentation/\(self.docID!)/\(doc.title!)").setValue(url)
        }
    }
}







