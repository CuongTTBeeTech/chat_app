//
//  ChatViewController.swift
//  Chat_App
//
//  Created by m1 on 06/12/2022.
//

import UIKit
import RxSwift
import RxDataSources

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableViewChat: UITableView!
    @IBOutlet weak var viewChat: UIView!
    @IBOutlet weak var textFieldMessage: UITextView!
    
    var imagePicker = UIImagePickerController()
    
    private let disposeBag = DisposeBag()
    
    var chatViewModel = ChatViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        guard let userOpposite = self.chatViewModel.userOpposite else {
            return
        }
        self.title = userOpposite.username
        
        // rotate tableView
        tableViewChat.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        
        // setup TextView
        textFieldMessage.layer.cornerRadius = 8
        textFieldMessage.isScrollEnabled = false
        textFieldMessage.textContainer.maximumNumberOfLines = 0
        
        // bind listChat to tableView
        self.chatViewModel.listChatLiveData.bind(to: self.tableViewChat.rx.items(dataSource: self.dataSource())).disposed(by: disposeBag)
        
        
        // binding inputText to textField
        self.textFieldMessage.rx.text.orEmpty.subscribe(onNext: {text in
            self.chatViewModel.chatTextInput.accept(text)
        }).disposed(by: disposeBag)
        
        // get messages
        chatViewModel.getMessages()
    }
    
    @IBAction func didTabSendMessage(_ sender: Any) {
        let mes = textFieldMessage.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if mes.isEmpty {
            return
        }
        
        chatViewModel.sendTextMessage(mess: mes, onCompletion: {[weak self] in
            self?.textFieldMessage.text = ""
            self?.tableViewChat.scrollToTop()
        })
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
    
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.chatViewModel.sendImageMessage(image: image, onCompletion: {[weak self] in
            self?.tableViewChat.scrollToTop()
        })
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension ChatViewController {
    func dataSource() -> RxTableViewSectionedReloadDataSource<MultipleSectionModel> {
        
        return RxTableViewSectionedReloadDataSource<MultipleSectionModel>(
                configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
                    switch dataSource[indexPath].type {
                    case 1:
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "opposite_text") as? OppositeTextMessageTableViewCell else {
                            return UITableViewCell()
                        }
                        cell.configure(item: item)
                        return cell
                    case 2:
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "self_text") as? SelfTextMessageTableViewCell else {
                            return UITableViewCell()
                        }
                        cell.configure(item: item)
                        return cell
                    case 3:
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "opposite_img") as? OppositeImageMessageTableViewCell else {
                            return UITableViewCell()
                        }
                        cell.configure(item: item)
                        return cell
                    case 4:
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "self_img") as? SelfImageMessageTableViewCell else {
                            return UITableViewCell()
                        }
                        cell.configure(item: item)
                        return cell
                    default:
                        return UITableViewCell()
                    }
                })
        
    }
}
