//
//  SignupViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/28.
//

import UIKit
import FirebaseAuth

class SignupViewController: BaseViewController {
    lazy var signupLabel: UILabel = {
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
    lazy var accountLabel: UILabel = {
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
    lazy var accountTextField: BaseTextField = {
        let accountTextField = BaseTextField()
        accountTextField.attributedText = UIFont.fontStyle(
            font: .regular,
            title: "請輸入你的e-mail",
            size: 15,
            textColor: .B3 ?? .black,
            letterSpacing: 3)
        accountTextField.textAlignment = .center
        accountTextField.delegate = self
        accountTextField.tag = 1
        return accountTextField
    }()
    lazy var passwordLabel: UILabel = {
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
    lazy var passwordTextField: BaseTextField = {
        let passwordTextField = BaseTextField()
        passwordTextField.attributedText = UIFont.fontStyle(
            font: .regular,
            title: "請輸入至少６位數密碼",
            size: 15,
            textColor: .B3 ?? .black,
            letterSpacing: 3)
        passwordTextField.textAlignment = .center
        passwordTextField.delegate = self
        passwordTextField.tag = 2
        return passwordTextField
    }()
    lazy var nameLabel: UILabel = {
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
    lazy var nameTextField: BaseTextField = {
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
    lazy var signupButton: BaseButton = {
        let signupButton = BaseButton()
        signupButton.setAttributedTitle(UIFont.fontStyle(
                font: .semibold,
                title: "確定註冊",
                size: 20,
                textColor: .B2 ?? .black,
                letterSpacing: 3), for: .normal)
        signupButton.titleLabel?.textAlignment = .center
        signupButton.addTarget(self, action: #selector(signupButtonPressed), for: .touchUpInside)
        return signupButton
    }()
    let alertVC = AlertViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        [signupLabel,
         accountLabel, accountTextField,
         passwordLabel, passwordTextField,
         nameLabel, nameTextField,
         signupButton].forEach { view.addSubview($0) }
        signupLabel.snp.makeConstraints { make in
            make.top.equalTo(view).offset(100)
            make.centerX.equalTo(view)
        }
        accountLabel.snp.makeConstraints { make in
            make.top.equalTo(signupLabel.snp.bottom).offset(80)
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
            make.top.equalTo(nameTextField.snp.bottom).offset(100)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
    }
    @objc func signupButtonPressed() {
        guard let account = accountTextField.text, !account.isEmpty, account != "請輸入你的e-mail",
                let password = passwordTextField.text, !password.isEmpty, password != "請輸入至少６位數密碼",
                let name = nameTextField.text, !name.isEmpty, name != "暱稱之後可在個人頁面更改"
        else {
            let alert = alertVC.showAlert(title: "註冊錯誤", message: "請輸入帳號、密碼及暱稱")
            present(alert, animated: true, completion: nil)
            return
        }
        Auth.auth().createUser(withEmail: account, password: password) { result, error in
            guard let user = result?.user,
                  error == nil else {
                print(error?.localizedDescription)
                return
            }
            print(user.email, user.uid)
       }
    }
}
extension SignupViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
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
            guard let enteredName = passwordTextField.text else {
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
