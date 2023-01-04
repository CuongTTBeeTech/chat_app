//
//  ListUsersViewController.swift
//  Chat_App
//
//  Created by m1 on 06/12/2022.
//

import UIKit
import RxSwift

class ListUsersViewController: UIViewController {
    
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var tableViewUsers: UITableView!
    
    private let disposeBag = DisposeBag()
    
    let viewModel = ListUsersViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Chat"
        labelUsername.text = self.viewModel.username
        
        tableViewUsers.delegate = self
        
        // binding data to tableView
        self.viewModel.listUsersLiveData.bind(to: tableViewUsers.rx.items(cellIdentifier: "user")) { (index, user, cell) in
            cell.textLabel?.text = user.username
        }.disposed(by: disposeBag)
    
        // get list users
        viewModel.getUsers()
        
    }
    
}

extension ListUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let vc = storyboard?.instantiateViewController(identifier: "chat") as? ChatViewController else {
            return
        }
        
        vc.chatViewModel.userOpposite = User(userId: self.viewModel.listUsers[indexPath.row].userId, username: self.viewModel.listUsers[indexPath.row].username)
        vc.chatViewModel.userSelf = User(userId: self.viewModel.userId, username: self.viewModel.username)
        navigationController?.pushViewController(vc, animated: true)
    }
}
