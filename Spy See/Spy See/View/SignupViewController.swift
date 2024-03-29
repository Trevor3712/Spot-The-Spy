//
//  SignupViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/28.
//

import UIKit
import FirebaseAuth

class SignupViewController: BaseViewController {
    private lazy var signupLabel: UILabel = {
        let signupLabel = UILabel()
        signupLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "註冊",
            size: 30,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        signupLabel.textAlignment = .center
        return signupLabel
    }()
    private lazy var containerView = UIView()
    private lazy var accountLabel: UILabel = {
        let accountLabel = UILabel()
        accountLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "你的帳號",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        accountLabel.textAlignment = .center
        return accountLabel
    }()
    private lazy var accountTextField: BaseTextField = {
        let accountTextField = BaseTextField()
        accountTextField.attributedText = UIFont.fontStyle(
            font: .regular,
            title: "請輸入你的e-mail",
            size: 15,
            textColor: .B3 ?? .black,
            letterSpacing: 3)
        accountTextField.textAlignment = .center
        accountTextField.keyboardType = .emailAddress
        accountTextField.autocorrectionType = .no
        accountTextField.delegate = self
        accountTextField.tag = 1
        return accountTextField
    }()
    private lazy var passwordLabel: UILabel = {
        let passwordLabel = UILabel()
        passwordLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "你的密碼",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        passwordLabel.textAlignment = .center
        return passwordLabel
    }()
    private lazy var passwordTextField: BaseTextField = {
        let passwordTextField = BaseTextField()
        passwordTextField.attributedText = UIFont.fontStyle(
            font: .regular,
            title: "請輸入至少６位數密碼",
            size: 15,
            textColor: .B3 ?? .black,
            letterSpacing: 3)
        passwordTextField.textAlignment = .center
        passwordTextField.keyboardType = .emailAddress
        passwordTextField.autocorrectionType = .no
        passwordTextField.delegate = self
        passwordTextField.tag = 2
        return passwordTextField
    }()
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "你的暱稱",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        nameLabel.textAlignment = .center
        return nameLabel
    }()
    private lazy var nameTextField: BaseTextField = {
        let nameTextField = BaseTextField()
        nameTextField.attributedText = UIFont.fontStyle(
            font: .regular,
            title: "暱稱之後可在個人頁面更改",
            size: 15,
            textColor: .B3 ?? .black,
            letterSpacing: 3)
        nameTextField.textAlignment = .center
        nameTextField.delegate = self
        nameTextField.tag = 3
        return nameTextField
    }()
    private lazy var signupButton: BaseButton = {
        let signupButton = BaseButton()
        signupButton.setNormal("確定註冊")
        signupButton.setHighlighted("確定註冊")
        signupButton.addTarget(self, action: #selector(signupButtonPressed), for: .touchUpInside)
        return signupButton
    }()
    private let alertVC = AlertViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        [signupLabel, containerView, signupButton].forEach { view.addSubview($0) }
        [accountLabel, accountTextField].forEach { containerView.addSubview($0) }
        [passwordLabel, passwordTextField].forEach { containerView.addSubview($0) }
        [nameLabel, nameTextField].forEach { containerView.addSubview($0) }
        signupLabel.snp.makeConstraints { make in
            make.bottom.equalTo(containerView.snp.top).offset(-50)
            make.centerX.equalTo(view)
        }
        containerView.snp.makeConstraints { make in
            make.top.equalTo(signupLabel.snp.bottom).offset(50)
            make.centerX.centerY.equalTo(view)
            make.width.equalTo(300)
            make.height.equalTo(400)
        }
        accountLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView)
            make.left.equalTo(accountTextField)
        }
        accountTextField.snp.makeConstraints { make in
            make.top.equalTo(accountLabel.snp.bottom).offset(20)
            make.centerX.equalTo(view)
            make.width.equalTo(300)
            make.height.equalTo(40)
        }
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(accountTextField.snp.bottom).offset(50)
            make.left.equalTo(accountTextField)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(20)
            make.centerX.equalTo(view)
            make.width.equalTo(300)
            make.height.equalTo(40)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(50)
            make.left.equalTo(accountTextField)
        }
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
            make.centerX.equalTo(view)
            make.width.equalTo(300)
            make.height.equalTo(40)
        }
        signupButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(80)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: SystemImageConstants.chevronLeft),
            style: .plain,
            target: self,
            action: #selector(backButtonPressed)
        )
        backButton.tintColor = .B1
        navigationItem.leftBarButtonItem = backButton
    }
    @objc private func signupButtonPressed() {
        guard let clickUrl = clickUrl else {
            return
        }
        playSeAudio(from: clickUrl)
        vibrate()
        guard let account = accountTextField.text, !account.isEmpty, account != "請輸入你的e-mail" else {
            signUpErrorAlert()
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty, password != "請輸入至少６位數密碼" else {
            signUpErrorAlert()
            return
        }
        guard let name = nameTextField.text, !name.isEmpty, name != "暱稱之後可在個人頁面更改" else {
            signUpErrorAlert()
            return
        }
        Auth.auth().createUser(withEmail: account, password: password) { result, error in
            guard result?.user != nil, error == nil else {
                let alert = self.alertVC.showAlert(title: "註冊錯誤", message: error?.localizedDescription ?? "")
                self.present(alert, animated: true, completion: nil)
                return
            }
            let alert = self.alertVC.showAlert(title: "註冊成功", message: "馬上開始遊戲！") {
                self.setNameData()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let tabBarController = storyboard.instantiateViewController(
                    withIdentifier: "TabBarController") as? UITabBarController else {
                    return
                }
                self.navigationController?.pushViewController(tabBarController, animated: true)
            }
            self.present(alert, animated: true)
        }
    }
    private func signUpErrorAlert() {
        let alert = alertVC.showAlert(title: "註冊錯誤", message: "請輸入帳號、密碼及暱稱")
        present(alert, animated: true, completion: nil)
    }
    private func setNameData() {
        let name = nameTextField.text
        let userEmail = accountTextField.text
        UserDefaults.standard.setValue(userEmail, forKey: UDConstants.userEmail)
        let data: [String: Any] = [FirestoreConstans.name: name as Any]
        FirestoreManager.shared.setData(
            collection: FirestoreConstans.users,
            key: FirestoreConstans.userEmail,
            data: data)
    }
    @objc private func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
}
extension SignupViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let editingUrl = editingUrl else {
            return
        }
        playSeAudio(from: editingUrl)
        vibrate()
        if textField.tag == 1 {
            accountTextField.text = ""
        } else if textField.tag == 2 {
            passwordTextField.text = ""
        } else {
            nameTextField.text = ""
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            guard let enteredAccount = accountTextField.text else {
                return
            }
            let styledAccount = UIFont.fontStyle(
                font: .regular,
                title: enteredAccount,
                size: 15,
                textColor: .B2 ?? .black,
                letterSpacing: 3)
            accountTextField.attributedText = styledAccount
        } else if textField.tag == 2 {
            guard let enteredPassword = passwordTextField.text else {
                return
            }
            let styledPassword = UIFont.fontStyle(
                font: .regular,
                title: enteredPassword,
                size: 15,
                textColor: .B2 ?? .black,
                letterSpacing: 3)
            passwordTextField.attributedText = styledPassword
        } else {
            guard let enteredName = nameTextField.text else {
                return
            }
            let styledName = UIFont.fontStyle(
                font: .regular,
                title: enteredName,
                size: 15,
                textColor: .B2 ?? .black,
                letterSpacing: 3)
            nameTextField.attributedText = styledName
        }
    }
}
