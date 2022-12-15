//
//  SelfTextMessageTableViewCell.swift
//  Chat_App
//
//  Created by m1 on 08/12/2022.
//

import UIKit

class SelfTextMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbCreateTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
