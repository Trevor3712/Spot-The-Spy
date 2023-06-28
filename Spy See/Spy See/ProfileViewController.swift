//
//  ProfileViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: BaseViewController {
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "你的暱稱",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 3)
        return nameLabel
    }()
    lazy var nameTextField: BaseTextField = {
        let nameTextField = BaseTextField()
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = UIColor.B1?.cgColor
        nameTextField.layer.cornerRadius = 20
        nameTextField.clipsToBounds = true
        nameTextField.textAlignment = .center
        nameTextField.delegate = self
        return nameTextField
    }()
    lazy var infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.attributedText = UIFont.fontStyle(
            font: .regular,
            title: "*點擊暱稱後可進行修改",
            size: 15,
            textColor: .B3 ?? .black,
            letterSpacing: 0)
        nameTextField.textAlignment = .center
        return infoLabel
    }()
    lazy var deleteButton: BaseButton = {
        let deleteButton = BaseButton()
        deleteButton.setAttributedTitle(UIFont.fontStyle(
                font: .semibold,
                title: "刪除帳號",
                size: 20,
                textColor: .B2 ?? .black,
                letterSpacing: 3), for: .normal)
        deleteButton.titleLabel?.textAlignment = .center
//        loginButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        return deleteButton
    }()
    var userName: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        [nameTextField, nameLabel, infoLabel, deleteButton].forEach { view.addSubview($0) }
        nameTextField.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.centerY).offset(-50)
            make.centerX.equalTo(view)
            make.width.equalTo(350)
            make.height.equalTo(100)
        }
        nameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(nameTextField.snp.top).offset(-30)
            make.centerX.equalTo(view)
        }
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(20)
            make.centerX.equalTo(view)
        }
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(200)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserName()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNameData()
    }
    func setNameData() {
        let user = Firestore.firestore().collection("Users")
        guard let userId = Auth.auth().currentUser?.email else {
            return
        }
        let documentRef = user.document(userId)
        let name = nameTextField.text
        documentRef.setData(["name": name ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
            }
        }
    }
    func getUserName() {
        let room = Firestore.firestore().collection("Users")
        guard let userId = Auth.auth().currentUser?.email else {
            return
        }
        let documentRef = room.document(userId)
        documentRef.getDocument { (document, error) in
            if let document = document, let name = document.data()?["name"] as? String {
                self.nameTextField.attributedText = UIFont.fontStyle(
                    font: .semibold,
                    title: name,
                    size: 35,
                    textColor: .B2 ?? .black,
                    letterSpacing: 5)
            } else {
                print("Failed to retrieve player name")
                self.nameTextField.attributedText = UIFont.fontStyle(
                    font: .semibold,
                    title: "超帥的暱稱",
                    size: 35,
                    textColor: .B2 ?? .black,
                    letterSpacing: 5)
            }
        }
    }
}
extension ProfileViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameTextField.text = ""
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let enteredText = nameTextField.text else {
            return
        }
        let styledText = UIFont.fontStyle(
            font: .semibold,
            title: enteredText,
            size: 35,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        nameTextField.attributedText = styledText
    }
}
