//
//  AddDriverDocViewController.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/19/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class AddDriverDocViewController: UIViewController {

    var controller: ConfigureDocumentationViewController?
    
    @IBOutlet weak var type: UISegmentedControl!
    
    @IBOutlet weak var docTitle: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Add Required Documents"
    }
    
    @IBAction func save(_ sender: UIButton) {
        let index = controller?.backend.documents.count
        let docType = type.titleForSegment(at: type.selectedSegmentIndex)
        controller?.backend.addRequirement(title: docTitle.text!, type: docType!, index: index!)
        performSegue(withIdentifier: "rewindToConfigureDocs", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
}
