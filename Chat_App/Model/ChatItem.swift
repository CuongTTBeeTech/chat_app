//
//  ChatItem.swift
//  Chat_App
//
//  Created by m1 on 07/12/2022.
//

import Foundation

struct ChatItem {
    let id: Int
    let userSelfId: String
    let userOppositeId: String
    let message: String
    let type: Int
    let createTime: Int
    
    func formatTime() -> String {
        let timeResult = (self.createTime)
        let date = Date(timeIntervalSince1970: TimeInterval(timeResult))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        
        return localDate
    }
}
