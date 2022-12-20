//
//  ListUsersViewController.swift
//  Chat_App
//
//  Created by m1 on 06/12/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ListUsersViewController: UIViewController {
    
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var tableViewUsers: UITableView!
    
    var username: String = ""
    var userId: String = ""
    var listUsers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Chat"
        labelUsername.text = username
        
        tableViewUsers.delegate = self
        tableViewUsers.dataSource = self
        
        let db = Firestore.firestore()
        db.collection("users")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    guard let querySnapshot = querySnapshot else {
                        return
                    }
                    
                    querySnapshot.documents.forEach({ doc in
                        let userDoc = User(userId: doc.documentID, username: doc.data()["username"] as? String ?? "")
                        if self.userId != doc.documentID {
                            self.listUsers.append(userDoc)
                        }
                    })
                    
                    self.tableViewUsers.reloadData()
                }
        }
    }
    
}


