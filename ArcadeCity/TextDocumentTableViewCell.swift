//
//  TextDocumentTableViewCell.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/20/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class TextDocumentTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var textField: UITextField!
    weak var controller: DriverDocumentationViewController!
    var indexPath: IndexPath!
    var screenIsMovedUp = false
    var document: Document! {
        didSet {
            title.text = document.title
            title.lineBreakMode = .byWordWrapping
            title.numberOfLines = 0
            textField.text = document.value
            textField.addTarget(self, action: #selector(saveText), for: .editingDidEnd)
            textField.addTarget(self, action: #selector(linkToDismiss), for: .editingDidBegin)
            textField.delegate = self
            if controller.documentsAreForEditing == false {
                textField.isUserInteractionEnabled = false
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveScreen(up: false)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveScreen(up: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: 0)
        if let cell = controller.tableView.cellForRow(at: nextIndexPath) as? TextDocumentTableViewCell {
            cell.textField.becomeFirstResponder()
        }
        return true
    }
    
    func moveScreen(up: Bool) {
        if screenIsMovedUp == false {
            //only move screen up if textfield will be blocked by keyboard
            let cellRect = controller.tableView.rectForRow(at: indexPath)
            let cellRectGlobal = controller.tableView.convert(cellRect, to: nil)
            if (cellRectGlobal.origin.y + textField.frame.origin.y + textField.frame.size.height + 20) < (UIScreen.main.bounds.height - 165) {
                return
            }
        }
        var movementDistance: CGFloat = 165
        if up == true {
            movementDistance = -movementDistance
            screenIsMovedUp = true
        } else {
            screenIsMovedUp = false
        }
       controller.view.frame = controller.view.frame.offsetBy(dx: 0, dy: movementDistance)
    }
    
    func linkToDismiss() {
        controller.cellToDismissKeybaord = self
    }
    
    func saveText() {
        print("saved")
        document.valueToSave = textField.text
        document.value = textField.text
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
