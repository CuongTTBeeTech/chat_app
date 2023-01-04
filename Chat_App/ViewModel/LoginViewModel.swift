//
//  LoginViewModel.swift
//  Chat_App
//
//  Created by m1 on 03/01/2023.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import RxSwift
import RxCocoa

class LoginViewModel: NSObject {
    
    let db = Firestore.firestore()
    
    var usernameLiveData = BehaviorRelay(value: "")
    var passwordLiveData = BehaviorRelay(value: "")
    
    private let disposeBag = DisposeBag()
    
    override init() {
        super.init()
    }
    
    func login(username: String, password: String, onError: @escaping ((String) -> Void), onCompletion: @escaping (QuerySnapshot) -> Void) {
        
        db.collection("users").whereField("username", isEqualTo: username).whereField("password", isEqualTo: password)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    onError("Error getting documents: \(err)")
                } else {
                    
                    guard let querySnapshot = querySnapshot else {
                        return
                    }
                    if querySnapshot.documents.count == 0 {
                        onError("No user found")
                        return
                    }
                    
                    onCompletion(querySnapshot)
                    
                }
        }
        
    }
}
