//
//  ListUsersViewController.swift
//  Chat_App
//
//  Created by m1 on 06/12/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import RxSwift
import RxCocoa

class ListUsersViewController: UIViewController {
    
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var tableViewUsers: UITableView!
    
    var username: String = ""
    var userId: String = ""
    var listUsers: [User] = []
    var listUsersLiveData = BehaviorRelay<[User]>(value: [])
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Chat"
        labelUsername.text = username
        
        tableViewUsers.delegate = self
        
        // binding data to tableView
        listUsersLiveData.bind(to: tableViewUsers.rx.items(cellIdentifier: "user")) { (index, user, cell) in
            cell.textLabel?.text = user.username
        }.disposed(by: disposeBag)
       
        
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

extension ListUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let vc = storyboard?.instantiateViewController(identifier: "chat") as? ChatViewController else {
            return
        }
        vc.chatViewModel.userOpposite = User(userId: listUsers[indexPath.row].userId, username: listUsers[indexPath.row].username)
        vc.chatViewModel.userSelf = User(userId: self.userId, username: self.username)
        navigationController?.pushViewController(vc, animated: true)
    }
}
