//
//  MyMessageTableViewCell.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 8/9/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import UIKit

class MyMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageText: UILabel!
    var cellColor = UIColor(red:0.26, green:0.72, blue:0.98, alpha:0.2)
    var createdBubble = false
    var bubble = UIView()
    var widthConstraint: NSLayoutConstraint?
    var label = UILabel()
    var message: Message? {
        didSet {
            let str = NSString(string: (message?.string)! + "\n" + TimeAgo.get((message?.date)!))
            let rangeOfDate = str.range(of: TimeAgo.get((message?.date)!))
            let attributedString = NSMutableAttributedString(string: str as String, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 15)])
            attributedString.setAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 8)], range: rangeOfDate)
            messageText.attributedText = attributedString
            messageText.lineBreakMode = .byWordWrapping
            messageText.numberOfLines = 0
            messageText.sizeToFit()
            addBubbleBehindMessage()
        }
    }
    
    func addBubbleBehindMessage() {
        if createdBubble == true {
            bubble.removeFromSuperview()
        }
        createdBubble = true
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 260, height: 2000))
        label.attributedText = messageText.attributedText
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.sizeToFit()
        bubble = UIView(frame: label.frame)
        bubble.frame.origin.x = UIScreen.main.bounds.width - bubble.frame.size.width - 30
        bubble.frame.origin.y = 5
        bubble.frame.size.height = bubble.frame.size.height + 12
        bubble.frame.size.width = bubble.frame.size.width + 20
        bubble.backgroundColor = self.cellColor
        contentView.addSubview(bubble)
        bubble.layer.cornerRadius = 15
        bubble.layer.borderWidth = 1
        bubble.layer.borderColor = self.cellColor.cgColor
        bubble.layer.masksToBounds = true
        contentView.bringSubview(toFront: messageText)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
