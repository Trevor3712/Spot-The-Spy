//
//  ProfileViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/23.
//

import UIKit

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
    lazy var logoutButton: BaseButton = {
        let logoutButton = BaseButton()
        logoutButton.setNormal("登出帳號")
        logoutButton.setHighlighted("登出帳號")
        logoutButton.addTarget(self, action: #selector(logoutButtonPressed), for: .touchUpInside)
        return logoutButton
    }()
    lazy var deleteButton: BaseButton = {
        let deleteButton = BaseButton()
        deleteButton.setNormal("刪除帳號")
        deleteButton.setHighlighted("刪除帳號")
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        return deleteButton
    }()
    var userName: String?
    let alertVC = AlertViewController()
    var profileViewModel = ProfileViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationItem.hidesBackButton = true
        [nameTextField, nameLabel, infoLabel, logoutButton, deleteButton].forEach { view.addSubview($0) }
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
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(150)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(logoutButton.snp.bottom).offset(30)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileViewModel.getUserName { result in
            switch result {
            case .success(let name):
                self.nameTextField.attributedText = UIFont.fontStyle(
                    font: .semibold,
                    title: name,
                    size: 35,
                    textColor: .B2 ?? .black,
                    letterSpacing: 5)
            case .failure(let error):
                print("Error getting name:\(error)")
                self.nameTextField.attributedText = UIFont.fontStyle(
                    font: .semibold,
                    title: "超帥的暱稱",
                    size: 35,
                    textColor: .B2 ?? .black,
                    letterSpacing: 5)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let name = nameTextField.text ?? ""
        profileViewModel.setNameData(name: name)
    }
    @objc func deleteButtonPressed() {
        playSeAudio()
        vibrate()
        let alert = alertVC.showTwoAlert(title: "提示", message: "你確定要刪除帳號嗎？") {
            self.profileViewModel.deleteAuthData()
            self.profileViewModel.deleteStoreData()
            self.navigationController?.popToRootViewController(animated: true)
        }
        present(alert, animated: true)
    }
    @objc func logoutButtonPressed() {
        playSeAudio()
        vibrate()
        let alert = alertVC.showTwoAlert(title: "提示", message: "你確定要登出帳號嗎？") {
            UserDefaults.standard.removeObject(forKey: "userEmail")
            self.navigationController?.popToRootViewController(animated: true)
        }
        present(alert, animated: true)
    }
}
extension ProfileViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let editingUrl = editingUrl else {
            return
        }
        playSeAudio(from: editingUrl)
        vibrate()
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
