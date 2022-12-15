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
    
    @IBOutlet weak var textFieldMessage: UITextField!
    
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    // 1 left other
    // 2 right self
    var userOpposite: User!
    var userSelf: User!
    
    var listChat: [ChatItem] = []
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = userOpposite.username
        
        //        print("userIdSelf: \(userSelf!)  --  userIdOpposite: \(userOpposite!)")
        tableViewChat.dataSource = self
        tableViewChat.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        
        //        db.collection("chat_group").document("\(userSelf.username)-\(userSelf.userId)").collection("picky1Id1-pickyId2").getDocuments()
        
        // get messages
        getMessages()
        
        
    }
    
    func getMessages() {
        //            .addSnapshotListener({ docSnapshot, err in})
        
//        db.collection("chat_group").document("\(self.userSelf.username)-\(self.userSelf.userId)")
//            .collection("\(self.userSelf.userId)-\(self.userOpposite.userId)").order(by: "createTime", descending: true).getDocuments() { (querySnapshot, err) in
        db.collection("chat_group").document("\(self.userSelf.username)-\(self.userSelf.userId)")
            .collection("\(self.userSelf.userId)-\(self.userOpposite.userId)").order(by: "createTime", descending: true).addSnapshotListener() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    querySnapshot!.documents.forEach({ doc in
                        let chatItem = ChatItem(id: doc.data()["id"] as! Int, userSelfId: doc.data()["userSelfId"] as! String, userOppositeId: doc.data()["userOppositeId"] as! String, message: doc.data()["message"] as! String, type: doc.data()["type"] as! Int, createTime: doc.data()["createTime"] as! Int)
                        
                        self.listChat.append(chatItem)
                        
                    })
                    
                    self.tableViewChat.reloadData()
                }
            }
    }
    
    
    
    @IBAction func didTabSendMessage(_ sender: Any) {
        let mess = textFieldMessage.text ?? ""
        if mess.isEmpty {
            return
        }
        
        do {
            let timeStamp = Int(Date().timeIntervalSince1970)
            
            let itemChat: [String: Any] = [
                "createTime": timeStamp,
                "id": timeStamp,
                "message": mess,
                "type": 2,
                "userOppositeId": self.userOpposite.userId,
                "userSelfId": self.userSelf.userId
            ]
            
            db.collection("chat_group").document("\(self.userSelf.username)-\(self.userSelf.userId)").collection("\(self.userSelf.userId)-\(self.userOpposite.userId)").addDocument(data: itemChat)
            
            // add Another document for opposite
            let itemChatOpposite: [String: Any] = [
                "createTime": timeStamp,
                "id": timeStamp,
                "message": mess,
                "type": 1,
                "userOppositeId": self.userSelf.userId,
                "userSelfId": self.userOpposite.userId
            ]
            db.collection("chat_group").document("\(self.userOpposite.username)-\(self.userOpposite.userId)").collection("\(self.userOpposite.userId)-\(self.userSelf.userId)")
                .addDocument(data: itemChatOpposite)
            
            let item = ChatItem(id: timeStamp, userSelfId: self.userSelf.userId, userOppositeId: self.userOpposite.userId, message: mess, type: 2, createTime: timeStamp)
            self.listChat.insert(item, at: 0)
            textFieldMessage.text = ""
            
            tableViewChat.reloadData()
            
        } catch {
            print("Error writing to Firestore: \(error)")
        }
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
        
        
        storage.child("images/file.png").putData(imageData, metadata: nil, completion: {_ , error in
            guard error == nil else {
                print("Failed to upload")
                return
            }
            
            self.storage.child("images/file.png").downloadURL(completion: {url, error in
                guard let url = url, error == nil else {
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url: \(urlString)")
            })
        })
        
        
        let timeStamp = Int(Date().timeIntervalSince1970)
//        storage.child("images/file.png").putData(imageData, metadata: nil, completion: {_, error in
        storage.child("images/img_chat_\(self.userSelf.userId)_\(self.userOpposite.userId)_\(timeStamp).png").putData(imageData, metadata: nil, completion: {_, error in
            guard error == nil else {
                print("Failed to upload")
                return
            }

            self.storage.child("images/img_chat_\(self.userSelf.userId)_\(self.userOpposite.userId)_\(timeStamp).png").downloadURL(completion: {url, error in
                guard let url = url, error == nil else {
                    return
                }

                let urlString = url.absoluteString
                print("Download url: \(urlString)")

                // send message

                do {

                    let itemChat: [String: Any] = [
                        "createTime": timeStamp,
                        "id": timeStamp,
                        "message": urlString,
                        "type": 4,
                        "userOppositeId": self.userOpposite.userId,
                        "userSelfId": self.userSelf.userId
                    ]

                    self.db.collection("chat_group").document("\(self.userSelf.username)-\(self.userSelf.userId)").collection("\(self.userSelf.userId)-\(self.userOpposite.userId)").addDocument(data: itemChat)

                    // add Another document for opposite
                    let itemChatOpposite: [String: Any] = [
                        "createTime": timeStamp,
                        "id": timeStamp,
                        "message": urlString,
                        "type": 3,
                        "userOppositeId": self.userSelf.userId,
                        "userSelfId": self.userOpposite.userId
                    ]
                    self.db.collection("chat_group").document("\(self.userOpposite.username)-\(self.userOpposite.userId)").collection("\(self.userOpposite.userId)-\(self.userSelf.userId)")
                        .addDocument(data: itemChatOpposite)

                    let item = ChatItem(id: timeStamp, userSelfId: self.userSelf.userId, userOppositeId: self.userOpposite.userId, message: urlString, type: 4, createTime: timeStamp)
                    self.listChat.insert(item, at: 0)
                    self.textFieldMessage.text = ""

                    self.tableViewChat.reloadData()

                } catch {
                    print("Error writing to Firestore: \(error)")
                }
            })
        })
        
        // upload image data
        // get download url
        // save download url to userDefaults
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}




