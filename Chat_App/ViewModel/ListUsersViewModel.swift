//
//  ListUsersViewModel.swift
//  Chat_App
//
//  Created by m1 on 03/01/2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import RxSwift
import RxCocoa

class ListUsersViewModel: NSObject {
    
    var username: String = ""
    var userId: String = ""
    var listUsers: [User] = []
    var listUsersLiveData = BehaviorRelay<[User]>(value: [])
    
    override init() {
        super.init()
    }
    
    func getUsers() {
        let db = Firestore.firestore()
        db.collection("users")
            .getDocuments() { [weak self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    guard let querySnapshot = querySnapshot else {
                        return
                    }
                    
                    querySnapshot.documents.forEach({ doc in
                        let userDoc = User(userId: doc.documentID, username: doc.data()["username"] as? String ?? "")
                        if self?.userId != doc.documentID {
                            self?.listUsers.append(userDoc)
                        }
                    })
                    
                    self?.listUsersLiveData.accept(self?.listUsers ?? [])
                }
        }
    }
}
