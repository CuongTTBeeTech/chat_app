//
//  ChatViewController.swift
//  Chat_App
//
//  Created by m1 on 06/12/2022.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class ChatViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableViewChat: UITableView!
    @IBOutlet weak var viewChat: UIView!
    @IBOutlet weak var textFieldMessage: UITextView!
    
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    // 1 left other
    // 2 right self
    var userOpposite: User?
    var userSelf: User?
    
    var listChat: [ChatItem] = []
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        guard let userOpposite = self.userOpposite else {
            return
        }
        self.title = userOpposite.username
        
        tableViewChat.dataSource = self
        tableViewChat.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        
        textFieldMessage.layer.cornerRadius = 8
        textFieldMessage.textContainer.maximumNumberOfLines = 10
        textFieldMessage.delegate = self
        
        // get messages
        getMessages()
        
    }
    
    func getMessages() {
        //            .addSnapshotListener({ docSnapshot, err in})
        guard let userSelf = self.userSelf else {
            return
        }
        guard let userOpposite = self.userOpposite else {
            return
        }
        db.collection("chat_group").document("\(userSelf.username)-\(userSelf.userId)")
            .collection("\(userSelf.userId)-\(userOpposite.userId)").order(by: "createTime", descending: true).getDocuments() {[weak self] (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    guard let querySnapshot = querySnapshot else {
                        return
                    }
                    querySnapshot.documents.forEach({ doc in
                        let chatItem = ChatItem(id: doc.data()["id"] as? Int ?? 0, userSelfId: doc.data()["userSelfId"] as? String ?? "", userOppositeId: doc.data()["userOppositeId"] as? String ?? "", message: doc.data()["message"] as? String ?? "", type: doc.data()["type"] as? Int ?? 0, createTime: doc.data()["createTime"] as? Int ?? 0)
                        
                        self?.listChat.append(chatItem)
                        
                    })
                    
                    self?.tableViewChat.reloadData()
                }
            }
    }
    
    
    
    @IBAction func didTabSendMessage(_ sender: Any) {
        guard let mess = textFieldMessage.text else {
            return
        }
        
        guard let userOpposite = self.userOpposite else {
            return
        }
        guard let userSelf = self.userSelf else {
            return
        }
        
        let timeStamp = Int(Date().timeIntervalSince1970)
        
        let itemChat: [String: Any] = [
            "createTime": timeStamp,
            "id": timeStamp,
            "message": mess,
            "type": 2,
            "userOppositeId": userOpposite.userId,
            "userSelfId": userSelf.userId
        ]
        
        db.collection("chat_group").document("\(userSelf.username)-\(userSelf.userId)").collection("\(userSelf.userId)-\(userOpposite.userId)").addDocument(data: itemChat)
        
        // add Another document for opposite
        let itemChatOpposite: [String: Any] = [
            "createTime": timeStamp,
            "id": timeStamp,
            "message": mess,
            "type": 1,
            "userOppositeId": userSelf.userId,
            "userSelfId": userOpposite.userId
        ]
        db.collection("chat_group").document("\(userOpposite.username)-\(userOpposite.userId)").collection("\(userOpposite.userId)-\(userSelf.userId)")
            .addDocument(data: itemChatOpposite)
        
        // insert to table view
        let item = ChatItem(id: timeStamp, userSelfId: userSelf.userId, userOppositeId: userOpposite.userId, message: mess, type: 2, createTime: timeStamp)
        self.listChat.insert(item, at: 0)
        textFieldMessage.text = ""
        
        tableViewChat.reloadData()
        
    }
    
    @IBAction func didTabSelectImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        guard let imageData = image.pngData() else {
            return
        }
        
        guard let userOpposite = self.userOpposite else {
            return
        }
        
        guard let userSelf = self.userSelf else {
            return
        }
        
        
        storage.child("images/file.png").putData(imageData, metadata: nil, completion: { [weak self] _ , error in
            guard error == nil else {
                print("Failed to upload")
                return
            }
            
            self?.storage.child("images/file.png").downloadURL(completion: {url, error in
                guard let url = url, error == nil else {
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url: \(urlString)")
            })
        })
        
        
        let timeStamp = Int(Date().timeIntervalSince1970)
        storage.child("images/img_chat_\(userSelf.userId)_\(userOpposite.userId)_\(timeStamp).png").putData(imageData, metadata: nil, completion: { [weak self] _, error in
            guard error == nil else {
                print("Failed to upload")
                return
            }
            
            self?.storage.child("images/img_chat_\(userSelf.userId)_\(userOpposite.userId)_\(timeStamp).png").downloadURL(completion: {url, error in
                guard let url = url, error == nil else {
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url: \(urlString)")
                
                // send message
                let itemChat: [String: Any] = [
                    "createTime": timeStamp,
                    "id": timeStamp,
                    "message": urlString,
                    "type": 4,
                    "userOppositeId": userOpposite.userId,
                    "userSelfId": userSelf.userId
                ]
                
                self?.db.collection("chat_group").document("\(userSelf.username)-\(userSelf.userId)").collection("\(userSelf.userId)-\(userOpposite.userId)").addDocument(data: itemChat)
                
                // add Another document for opposite
                let itemChatOpposite: [String: Any] = [
                    "createTime": timeStamp,
                    "id": timeStamp,
                    "message": urlString,
                    "type": 3,
                    "userOppositeId": userSelf.userId,
                    "userSelfId": userOpposite.userId
                ]
                self?.db.collection("chat_group").document("\(userOpposite.username)-\(userOpposite.userId)").collection("\(userOpposite.userId)-\(userSelf.userId)")
                    .addDocument(data: itemChatOpposite)
                
                // insert to tableview
                let item = ChatItem(id: timeStamp, userSelfId: userSelf.userId, userOppositeId: userOpposite.userId, message: urlString, type: 4, createTime: timeStamp)
                self?.textFieldMessage.text = ""
                self?.listChat.insert(item, at: 0)
                self?.tableViewChat.reloadData()
            })
        })
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}




