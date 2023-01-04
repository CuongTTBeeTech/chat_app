//
//  SelfImageMessageTableViewCell.swift
//  Chat_App
//
//  Created by m1 on 08/12/2022.
//

import UIKit
import Kingfisher

class SelfImageMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var labelCreateTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.img.image = nil
    }

    func configure(item: ChatItem) {
        // image
        let urlString = item.message
        guard let url = URL(string: urlString) else {
            return
        }
        img.kf.setImage(with: url)
        // create time
        labelCreateTime?.text = item.createTime.toStringDate()
        
        transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
    }
}
