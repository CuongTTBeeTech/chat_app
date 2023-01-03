//
//  OppositeImageMessageTableViewCell.swift
//  Chat_App
//
//  Created by m1 on 08/12/2022.
//

import UIKit
import Kingfisher

class OppositeImageMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var labelCreateTime: UILabel!
    
    @IBOutlet weak var img: UIImageView!
    
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
        //            oppositeCellImage.img.af.setImage(withURL: url)
        img.kf.setImage(with: url)
        // create time
        let date = Date(timeIntervalSince1970: Double(item.createTime))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+7")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let strDate = dateFormatter.string(from: date)
        labelCreateTime?.text = strDate
        
//        let createTime: String = String(String(describing: NSDate(timeIntervalSince1970: TimeInterval(item.createTime))).dropLast(5))
//        labelCreateTime.text = createTime
        transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
    }
}
