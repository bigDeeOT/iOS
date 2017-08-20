//
//  ConfigureDocsBackend.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/18/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation
import Firebase

class ConfigureDocsBackend {
    
    var documents: [Document] = []
    var controller: ConfigureDocumentationViewController?
    var docToDelete: Document?
    func clear() {
        documents.removeAll()
    }
    func refresh() {
        documents.removeAll()
        pullRequirements()
    }
    
    func pullRequirements() {
        LoadRequests.gRef.child("Documentation Configuration").queryOrdered(byChild: "Index").observeSingleEvent(of: .value, with: { (snap) in
            guard snap.exists() else {return}
            for child in snap.children {
                let title = (child as! DataSnapshot).key
                let type = ((child as! DataSnapshot).value as! [String:Any])["Type"] as! String
                let index = ((child as! DataSnapshot).value as! [String:Any])["Index"] as! Int
                let document = Document(title: title, type: type, index: index)
                self.documents.append(document)
            }
            self.controller?.tableView.reloadData()
        })
    }
    
    func addRequirement(title: String, type: String, index: Int) {
        LoadRequests.gRef.child("Documentation Configuration/\(title)").setValue([
            "Index" : index,
            "Type"  : type,
            ])
        self.refresh()
        self.controller?.tableView.reloadData()
    }
    func removeRequirement(document: Document) {
        guard docToDelete == nil else {return}
        docToDelete = document
        changeRequirementIndex(title: document.title!, fromIndex: document.index!, toIndex: documents.count - 1)
    }
    func changeRequirementIndex(title: String, fromIndex: Int, toIndex: Int) {
        var requirementsToSave: [String:[String:Any]] = [:]
        LoadRequests.gRef.child("Documentation Configuration").queryOrdered(byChild: "Index").observeSingleEvent(of: .value, with: { (snapShot) in
            guard snapShot.exists() else {print("changeIndex error");return}
            for child in snapShot.children {
                let requirement = (child as! DataSnapshot).key
                var properties = (child as! DataSnapshot).value as! [String:Any]
                if fromIndex > toIndex {
                    if ((properties["Index"] as! Int) >= toIndex) && ((properties["Index"] as! Int) <= fromIndex) {
                        if requirement != title {
                            properties["Index"] = (properties["Index"] as! Int) + 1
                        }
                    }
                } else {
                    if ((properties["Index"] as! Int) <= toIndex) && ((properties["Index"] as! Int) >= fromIndex) {
                        if requirement != title {
                            properties["Index"] = (properties["Index"] as! Int) - 1
                        }
                    }
                }
                if requirement == title {
                    properties["Index"] = toIndex
                }
                requirementsToSave[requirement] = properties
            }
            LoadRequests.gRef.child("Documentation Configuration").setValue(requirementsToSave)
            if self.docToDelete != nil {
                LoadRequests.gRef.child("Documentation Configuration/\(self.docToDelete!.title!)").removeValue()
                self.docToDelete = nil
            }
            self.refresh()
        })
    }
}
