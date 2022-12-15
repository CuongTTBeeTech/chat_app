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
            let oppositeCellText = tableView.dequeueReusableCell(withIdentifier: "opposite_text", for: indexPath) as! OppositeTextMessageTableViewCell
            oppositeCellText.lbMessage?.text = listChat[indexPath.row].message
            oppositeCellText.lbCreateTime?.text = String(describing: NSDate(timeIntervalSince1970: TimeInterval(listChat[indexPath.row].createTime)))
            oppositeCellText.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            return oppositeCellText
        case 2:
            let selfCellText = tableView.dequeueReusableCell(withIdentifier: "self_text", for: indexPath) as! SelfTextMessageTableViewCell
            selfCellText.lbMessage?.text = listChat[indexPath.row].message
            selfCellText.lbCreateTime?.text = String(describing: NSDate(timeIntervalSince1970: TimeInterval(listChat[indexPath.row].createTime)))
            selfCellText.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            return selfCellText
        case 3:
            let oppositeCellImage = tableView.dequeueReusableCell(withIdentifier: "opposite_img", for: indexPath) as! OppositeImageMessageTableViewCell
            let urlString = listChat[indexPath.row].message
            let url = URL(string: urlString)
            oppositeCellImage.img.af.setImage(withURL: url!)
            
//            oppositeCellImage.img?.image = UIImage(url: URL(string: listChat[indexPath.row].message))
            oppositeCellImage.labelCreateTime.text = String(describing: NSDate(timeIntervalSince1970: TimeInterval(listChat[indexPath.row].createTime)))
            oppositeCellImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            return oppositeCellImage
        case 4:
            let selfCellImage = tableView.dequeueReusableCell(withIdentifier: "self_img", for: indexPath) as! SelfImageMessageTableViewCell
            let urlString = listChat[indexPath.row].message
            let url = URL(string: urlString)
            selfCellImage.img.af.setImage(withURL: url!)
//            selfCellImage.img?.image = UIImage(url: URL(string: listChat[indexPath.row].message))
            selfCellImage.labelCreateTime.text = String(describing: NSDate(timeIntervalSince1970: TimeInterval(listChat[indexPath.row].createTime)))
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
        
        let vc = storyboard?.instantiateViewController(identifier: "chat") as! ChatViewController
        vc.userOpposite = User(userId: listUsers[indexPath.row].userId, username: listUsers[indexPath.row].username)
        vc.userSelf = User(userId: self.userId, username: self.username)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension UIImage {
    convenience init?(url: URL?) {
        guard let url = url else { return nil }
        
        do {
            self.init(data: try Data(contentsOf: url))
        } catch {
            print("Cannot load image from url: \(url) with error: \(error)")
            return nil
        }
    }
}

extension UIImageView {

    
        func imageFromServerURL(_ URLString: String, placeHolder: UIImage?) {

        self.image = nil
        //If imageurl's imagename has space then this line going to work for this
        let imageServerUrl = URLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        

        if let url = URL(string: imageServerUrl) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in

                //print("RESPONSE FROM API: \(response)")
                if error != nil {
                    print("ERROR LOADING IMAGES FROM URL: \(String(describing: error))")
                    DispatchQueue.main.async {
                        self.image = placeHolder
                    }
                    return
                }
                DispatchQueue.main.async {
                    if let data = data {
                        if let downloadedImage = UIImage(data: data) {
                       
                            self.image = downloadedImage
                        }
                    }
                }
            }).resume()
        }
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


