//
//  SelfTextMessageTableViewCell.swift
//  Chat_App
//
//  Created by m1 on 08/12/2022.
//

import UIKit

class SelfTextMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var lbCreateTime: UILabel!
    
    @IBOutlet weak var lbMessage: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lbMessage.layer.cornerRadius = 8
        
        lbMessage.textContainer.maximumNumberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
