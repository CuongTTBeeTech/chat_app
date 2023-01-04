//
//  ChatViewModel.swift
//  Chat_App
//
//  Created by m1 on 03/01/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import RxCocoa
import RxSwift
import Kingfisher
import RxDataSources

class ChatViewModel: NSObject {
    var listChatLiveData = BehaviorRelay<[MultipleSectionModel]>(value: [])
    var listChat : [ChatItem] = []
    
    var chatTextInput = BehaviorRelay<String>(value: "")
    
    var userOpposite: User?
    var userSelf: User?
    
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    private let disposeBag = DisposeBag()
    
    override init() {
        super.init()
        bindingData()
    }
    
    func bindingData() {
        self.chatTextInput.asObservable().subscribe(onNext: { text in
            if text.isEmpty {
                return
            }
            
            print("text = \(text)")
        }).disposed(by: disposeBag)
    }
    
    func sendImageMessage(image: UIImage, onCompletion: @escaping () -> Void) {
        
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
                print("Failed to upload due to: \(String(describing: error?.localizedDescription))")
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
                
                self?.listChat.insert(item, at: 0)
                self?.listChatLiveData.accept([MultipleSectionModel(original: .TypeSelfText(type: 4, items: [item]), items: [item])] + (self?.listChatLiveData.value ?? []))
                onCompletion()
            })
        })
    }
    
    func sendTextMessage(mess: String, onCompletion: () -> Void) {

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

        self.listChatLiveData.accept([MultipleSectionModel(original: .TypeSelfText(type: 2, items: [item]), items: [item])] + self.listChatLiveData.value)
        
        onCompletion()
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
                    
                    
                    var data: [MultipleSectionModel] = []
                    self?.listChat.forEach({ chatItem in
                        switch chatItem.type {
                        case 1:
                            data.append(MultipleSectionModel(original: .TypeOppositeText(type: 1, items: [chatItem]), items: [chatItem]))
                        case 2:
                            data.append(MultipleSectionModel(original: .TypeSelfText(type: 2, items: [chatItem]), items: [chatItem]))
                        case 3:
                            data.append(MultipleSectionModel(original: .TypeOppositeImage(type: 3, items: [chatItem]), items: [chatItem]))
                        case 4:
                            data.append(MultipleSectionModel(original: .TypeSelfImage(type: 4, items: [chatItem]), items: [chatItem]))
                        default:
                            data.append(MultipleSectionModel(original: .TypeSelfImage(type: 4, items: [chatItem]), items: [chatItem]))
                        }
                    })
                    self?.listChatLiveData.accept(data)
                    
                }
            }
    }
}

enum MultipleSectionModel {
    case TypeOppositeText(type: Int, items: [ChatItem])
    case TypeSelfText(type: Int, items: [ChatItem])
    case TypeOppositeImage(type: Int, items: [ChatItem])
    case TypeSelfImage(type: Int, items: [ChatItem])
}

extension MultipleSectionModel: SectionModelType {
    typealias Item = ChatItem
    
    var items: [ChatItem] {
        switch self {
        case .TypeOppositeText(type: _, items: let items):
            return items.map{ $0 }
        case .TypeSelfText(type: _, items: let items):
            return items.map{ $0 }
        case .TypeOppositeImage(type: _, items: let items):
            return items.map{ $0 }
        case .TypeSelfImage(type: _, items: let items):
            return items.map{ $0 }
        }
    }
    
    init(original: MultipleSectionModel, items: [ChatItem]) {
        switch original {
        case .TypeOppositeText(type: _, items: _):
            self = .TypeOppositeText(type: 1, items: items)
        case .TypeSelfText(type: _, items: _):
            self = .TypeSelfText(type: 2, items: items)
        case .TypeOppositeImage(type: _, items: _):
            self = .TypeOppositeImage(type: 3, items: items)
        case .TypeSelfImage(type: _, items: _):
            self = .TypeSelfImage(type: 4, items: items)
        }
    }
    
}
