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
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    @IBOutlet weak var labelValidateUsername: UILabel!
    @IBOutlet weak var labelValidatePassword: UILabel!
    
    let db = Firestore.firestore()
    
    private var usernameLiveData = BehaviorRelay(value: "")
    private var passwordLiveData = BehaviorRelay(value: "")
    
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        bindUI()
    }
    
    func bindUI() {
        // bind textField username to usernameLiveData
        self.tfUsername.rx.text.orEmpty
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .asObservable()
            .bind(to: self.usernameLiveData)
            .disposed(by: disposeBag)
        
        self.usernameLiveData.asObservable().subscribe(onNext: {[weak self] text in
            if text.isEmpty {
                self?.validateUsername(isValidated: false)
            } else {
                self?.validateUsername(isValidated: true)
            }
        }).disposed(by: disposeBag)
        
        // bind textField password to passwordLiveData
        self.tfPassword.rx.text.orEmpty
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .asObservable()
            .bind(to: self.passwordLiveData)
            .disposed(by: disposeBag)
        
        self.passwordLiveData.asObservable().subscribe(onNext: {[weak self] text in
            if text.isEmpty {
                self?.validatePassword(isValidated: false)
            } else {
                self?.validatePassword(isValidated: true)
            }
        }).disposed(by: disposeBag)
    }
    
    @IBAction func btnLoginClick(_ sender: Any) {
        let username = tfUsername.text ?? ""
        let password = tfPassword.text ?? ""
        
        if (username.isEmpty || password.isEmpty) {
            showAlert(title: "Alert", message: "Missing required field")
            return
        }
        
        
        
        db.collection("users").whereField("username", isEqualTo: username).whereField("password", isEqualTo: password)
            .getDocuments() { [weak self] (querySnapshot, err) in
                if let err = err {
                    self?.showAlert(title: "Alert", message: "Error getting documents: \(err)")
                } else {
                    
                    guard let querySnapshot = querySnapshot else {
                        return
                    }
                    if querySnapshot.documents.count == 0 {
                        self?.showAlert(title: "Alert", message: "No user found")
                        return
                    }
                    
                    guard let vc = self?.storyboard?.instantiateViewController(identifier: "users") as? ListUsersViewController else {
                        return
                    }
                    vc.username = querySnapshot.documents[0]["username"] as? String ?? ""
                    vc.userId = querySnapshot.documents[0].documentID
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                }
        }
        
        
    }
    
}

extension ViewController {
    func validateUsername(isValidated: Bool) {
        if !isValidated {
            self.labelValidateUsername.isHidden = false
        } else {
            self.labelValidateUsername.isHidden = true
            self.labelValidateUsername.text = "Username is required"
        }
    }
    
    func validatePassword(isValidated: Bool) {
        if !isValidated {
            self.labelValidatePassword.isHidden = false
        } else {
            self.labelValidatePassword.isHidden = true
            self.labelValidatePassword.text = "Password is required"
        }
    }
}
