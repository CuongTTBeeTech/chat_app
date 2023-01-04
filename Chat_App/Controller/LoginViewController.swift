//
//  ViewController.swift
//  Chat_App
//
//  Created by m1 on 06/12/2022.
//

import UIKit
import RxSwift

class LoginViewController: UIViewController {
    
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var labelValidateUsername: UILabel!
    @IBOutlet weak var labelValidatePassword: UILabel!
    
    private let disposeBag = DisposeBag()
    
    let viewModel = LoginViewModel()
    
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
            .bind(to: self.viewModel.usernameLiveData)
            .disposed(by: disposeBag)
        
        self.viewModel.usernameLiveData.asObservable().subscribe(onNext: {[weak self] text in
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
            .bind(to: self.viewModel.passwordLiveData)
            .disposed(by: disposeBag)
        
        self.viewModel.passwordLiveData.asObservable().subscribe(onNext: {[weak self] text in
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
        
        viewModel.login(username: username, password: password, onError: {[weak self] error in
            self?.showAlert(title: "Alert", message: "Error: \(String(describing: error))")
        }, onCompletion: {[weak self] querySnapshot in
            guard let vc = self?.storyboard?.instantiateViewController(identifier: "users") as? ListUsersViewController else {
                return
            }
            vc.viewModel.username = querySnapshot.documents[0]["username"] as? String ?? ""
            vc.viewModel.userId = querySnapshot.documents[0].documentID
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        
    
        
        
    }
    
}

extension LoginViewController {
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
