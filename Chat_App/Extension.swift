//
//  Extension.swift
//  Chat_App
//
//  Created by m1 on 06/12/2022.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func showAlert(title: String, message: String) {
        
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listChat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch listChat[indexPath.row].type {
        case 1:
            guard let oppositeCellText = tableView.dequeueReusableCell(withIdentifier: "opposite_text", for: indexPath) as? OppositeTextMessageTableViewCell else {
                return UITableViewCell()
            }
            // message
            oppositeCellText.lbMessage?.text = listChat[indexPath.row].message
            let fixedWidth = oppositeCellText.lbMessage.frame.size.width
            let newSize = oppositeCellText.lbMessage.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            oppositeCellText.lbMessage.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            // create time
            let createTime: String = String(String(describing: NSDate(timeIntervalSince1970: TimeInterval(listChat[indexPath.row].createTime))).dropLast(5))
            oppositeCellText.lbCreateTime?.text = createTime
            oppositeCellText.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            return oppositeCellText
        case 2:
            guard let selfCellText = tableView.dequeueReusableCell(withIdentifier: "self_text", for: indexPath) as? SelfTextMessageTableViewCell else {
                return UITableViewCell()
            }
            // message
            selfCellText.lbMessage?.text = listChat[indexPath.row].message
            let fixedWidth = selfCellText.lbMessage.frame.size.width
            let newSize = selfCellText.lbMessage.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            selfCellText.lbMessage.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            // create time
            let createTime: String = String(String(describing: NSDate(timeIntervalSince1970: TimeInterval(listChat[indexPath.row].createTime))).dropLast(5))
            selfCellText.lbCreateTime?.text = createTime
            selfCellText.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            return selfCellText
        case 3:
            guard let oppositeCellImage = tableView.dequeueReusableCell(withIdentifier: "opposite_img", for: indexPath) as? OppositeImageMessageTableViewCell else {
                return UITableViewCell()
            }
            // image
            let urlString = listChat[indexPath.row].message
            guard let url = URL(string: urlString) else {
                return UITableViewCell()
            }
            oppositeCellImage.img.af.setImage(withURL: url)
            // create time
            let createTime: String = String(String(describing: NSDate(timeIntervalSince1970: TimeInterval(listChat[indexPath.row].createTime))).dropLast(5))
            oppositeCellImage.labelCreateTime.text = createTime
            oppositeCellImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            return oppositeCellImage
        case 4:
            guard let selfCellImage = tableView.dequeueReusableCell(withIdentifier: "self_img", for: indexPath) as? SelfImageMessageTableViewCell else {
                return UITableViewCell()
            }
            // image
            let urlString = listChat[indexPath.row].message
            guard let url = URL(string: urlString) else {
                return UITableViewCell()
            }
            selfCellImage.img.af.setImage(withURL: url)
            // create time
            let createTime: String = String(String(describing: NSDate(timeIntervalSince1970: TimeInterval(listChat[indexPath.row].createTime))).dropLast(5))
            selfCellImage.labelCreateTime.text = createTime
            selfCellImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            return selfCellImage
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let lineHeight = textFieldMessage.font?.lineHeight else {
            return
        }
        let numberOfLines = textFieldMessage.contentSize.height / lineHeight

        switch numberOfLines {
        case 0...10:
            // disable scroll
            textFieldMessage.isScrollEnabled = false
        default:
            print("")
            // enable scroll
//            textFieldMessage.isScrollEnabled = true
//            textFieldMessage.contentSize = CGSize(width: UIScreen.main.bounds.width, height: CGFloat(lineHeight * 5))
        }
    }
}

extension ListUsersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath)
        
        cell.textLabel?.text = listUsers[indexPath.row].username
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let vc = storyboard?.instantiateViewController(identifier: "chat") as? ChatViewController else {
            return
        }
        vc.userOpposite = User(userId: listUsers[indexPath.row].userId, username: listUsers[indexPath.row].username)
        vc.userSelf = User(userId: self.userId, username: self.username)
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}


