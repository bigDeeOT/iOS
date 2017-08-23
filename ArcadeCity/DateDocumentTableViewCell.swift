//
//  DateDocumentTableViewCell.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/20/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class DateDocumentTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    var controller: DriverDocumentationViewController!
    var datePicker: UIDatePicker!
    var indexPath: IndexPath!
    var document: Document! {
        didSet {
            title.text = document.title
            DispatchQueue.main.async {
                self.setupDatePicker()
            }
            setupDatePicker()
            setDate()
            if controller.documentsAreForEditing == false {
                datePicker.isUserInteractionEnabled = false
            }
        }
    }
    
    func setupDatePicker() {
        guard indexPath.row < controller.datePickerCache.count else {return}
        if datePicker != nil {
            datePicker.removeFromSuperview()
        } else {
            if controller.datePickerCache[indexPath.row] != nil {
                datePicker = controller.datePickerCache[indexPath.row]
            } else {
                datePicker = UIDatePicker()
                controller.datePickerCache[indexPath.row] = datePicker
            }
        }
        datePicker.datePickerMode = .date
        contentView.addSubview(datePicker)
        datePicker.frame.size.width = contentView.frame.size.width
        datePicker.frame.size.height = 60
        datePicker.frame.origin.y = 5
    }
    
    private func setDate() {
        datePicker.addTarget(self, action: #selector(saveDate), for: .editingChanged)
        guard document.value != nil else {return}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
        let dateValue = dateFormatter.date(from: document.value!)
        datePicker.date = dateValue!
    }
    
    func saveDate() {
        print("Date Saved")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
        let dateValue = dateFormatter.string(from: datePicker.date)
        document.value = dateValue
        document.valueToSave = dateValue
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
