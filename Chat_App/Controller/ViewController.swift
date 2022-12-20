//
//  ViewController.swift
//  Chat_App
//
//  Created by m1 on 06/12/2022.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var tfUsername: UITextField!
    
    @IBOutlet weak var tfPassword: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    
    @IBAction func btnLoginClick(_ sender: Any) {
        let username = tfUsername.text ?? ""
        let password = tfPassword.text ?? ""
        
        if (username.isEmpty || password.isEmpty) {
            showAlert(title: "Alert", message: "Missing required field")
            return
        }
        
        db.collection("users").whereField("username", isEqualTo: username).whereField("password", isEqualTo: password)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    self.showAlert(title: "Alert", message: "Error getting documents: \(err)")
                } else {
                    
                    guard let querySnapshot = querySnapshot else {
                        return
                    }
                    if querySnapshot.documents.count == 0 {
                        self.showAlert(title: "Alert", message: "No user found")
                        return
                    }
                    
                    guard let vc = self.storyboard?.instantiateViewController(identifier: "users") as? ListUsersViewController else {
                        return
                    }
                    vc.username = querySnapshot.documents[0]["username"] as? String ?? ""
                    vc.userId = querySnapshot.documents[0].documentID
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
        }
   
        
        
    }
    
}

