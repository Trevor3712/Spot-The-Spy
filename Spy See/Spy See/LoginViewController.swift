//
//  ViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/14.
//

import UIKit
import FirebaseAuth
import SnapKit

class LoginViewController: BaseViewController {
    lazy var logoImage: UIImageView = {
        let logoImage = UIImageView()
        logoImage.image = .asset(.spy)
        return logoImage
    }()
    lazy var labelCN1: UILabel = {
        let labelCN1 = UILabel()
        labelCN1.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "誰是",
            size: 50,
            textColor: .B2 ?? .black,
            letterSpacing: 15,
            obliqueness: 0.2)
        return labelCN1
    }()
    lazy var labelCN2: UILabel = {
        let labelCN2 = UILabel()
        labelCN2.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "臥底",
            size: 50,
            textColor: .B4 ?? .black,
            letterSpacing: 15,
            obliqueness: 0.2 )
        return labelCN2
    }()
    lazy var labelEN1: UILabel = {
        let labelEN1 = UILabel()
        labelEN1.attributedText = UIFont.fontStyle(
            font: .boldItalicEN,
            title: "SPOT",
            size: 45,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        return labelEN1
    }()
    lazy var labelEN2: UILabel = {
        let labelEN2 = UILabel()
        labelEN2.attributedText = UIFont.fontStyle(
            font: .boldItalicEN,
            title: "THE",
            size: 25,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        return labelEN2
    }()
    lazy var labelEN3: UILabel = {
        let labelEN3 = UILabel()
        labelEN3.attributedText = UIFont.fontStyle(
            font: .boldItalicEN,
            title: "SPY",
            size: 45,
            textColor: .B4 ?? .black,
            letterSpacing: 10)
        return labelEN3
    }()
    lazy var accountTextFileld: BaseTextField = {
        let accountTextFileld = BaseTextField()
        accountTextFileld.placeholder = "請輸入帳號"
        accountTextFileld.text = "1@1.com"
        accountTextFileld.delegate = self
        accountTextFileld.tag = 1
        return accountTextFileld
    }()
    lazy var passwordTextFileld: BaseTextField = {
        let passwordTextFileld = BaseTextField()
        passwordTextFileld.placeholder = "請輸入密碼"
        passwordTextFileld.text = "123456"
        passwordTextFileld.isSecureTextEntry = true
        passwordTextFileld.delegate = self
        passwordTextFileld.tag = 2
        return passwordTextFileld
    }()
    lazy var loginButton: BaseButton = {
        let loginButton = BaseButton()
        loginButton.setNormal("登入")
        loginButton.setHighlighted("登入")
        loginButton.setTitleColor(.B4, for: .highlighted)
        loginButton.addTarget(self, action: #selector(logInButtonPressed), for: .touchUpInside)
        return loginButton
    }()
    lazy var signupButton: BaseButton = {
        let signupButton = BaseButton()
        signupButton.setNormal("註冊")
        signupButton.setHighlighted("註冊")
        signupButton.addTarget(self, action: #selector(signupButtonPressed), for: .touchUpInside)
        return signupButton
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        [logoImage,
         labelCN1, labelCN2, labelEN1, labelEN2, labelEN3,
         accountTextFileld, passwordTextFileld,
         loginButton, signupButton].forEach { view.addSubview($0) }
        logoImage.snp.makeConstraints { make in
            make.top.equalTo(view).offset(120)
            make.centerX.equalTo(view)
            make.width.equalTo(130)
            make.height.equalTo(130)
        }
        labelCN1.snp.makeConstraints { make in
            make.top.equalTo(view).offset(300)
            make.left.equalTo(view).offset(125)
        }
        labelCN2.snp.makeConstraints { make in
            make.top.equalTo(labelCN1.snp.bottom)
            make.right.equalTo(view).offset(-30)
        }
        labelEN1.snp.makeConstraints { make in
            make.top.equalTo(labelCN1.snp.bottom)
            make.left.equalTo(view).offset(80)
        }
        labelEN2.snp.makeConstraints { make in
            make.top.equalTo(labelEN1.snp.bottom)
            make.left.equalTo(view).offset(125)
        }
        labelEN3.snp.makeConstraints { make in
            make.top.equalTo(labelCN2.snp.bottom)
            make.right.equalTo(view).offset(-90)
        }
        accountTextFileld.snp.makeConstraints { make in
            make.top.equalTo(labelEN3.snp.bottom).offset(12)
            make.centerX.equalTo(view)
            make.width.equalTo(260)
            make.height.equalTo(40)
        }
        passwordTextFileld.snp.makeConstraints { make in
            make.top.equalTo(accountTextFileld.snp.bottom).offset(30)
            make.centerX.equalTo(view)
            make.width.equalTo(260)
            make.height.equalTo(40)
        }
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextFileld.snp.bottom).offset(30)
            make.left.equalTo(passwordTextFileld)
            make.width.equalTo(115)
            make.height.equalTo(40)
        }
        signupButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextFileld.snp.bottom).offset(30)
            make.right.equalTo(passwordTextFileld)
            make.width.equalTo(115)
            make.height.equalTo(40)
        }
    }
    @objc func logInButtonPressed(_ sender: UIButton) {
        vibrate()
        Auth.auth().signIn(
            withEmail: accountTextFileld.text ?? "",
            password: passwordTextFileld.text ?? "") { _, error in
            guard error == nil else {
                let alertVC = AlertViewController()
                let alert = alertVC.showAlert(title: "登入錯誤", message: error?.localizedDescription ?? "")
                self.present(alert, animated: true)
                print(error?.localizedDescription ?? "")
                return
            }
            print("\(self.accountTextFileld.text ?? "") log in")
            guard let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else {
                return
            }
            self.navigationController?.pushViewController(tabBarController, animated: true)
            UserDefaults.standard.setValue(Auth.auth().currentUser?.email, forKey: "userEmail")
        }
    }
    @objc func signupButtonPressed() {
        vibrate()
        let signupVC = SignupViewController()
        navigationController?.pushViewController(signupVC, animated: true)
    }
}
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        vibrate()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            guard let enteredText = accountTextFileld.text else {
                return
            }
            let styledText = UIFont.fontStyle(
                font: .regular,
                title: enteredText,
                size: 15,
                textColor: .B2 ?? .black,
                letterSpacing: 3)
            accountTextFileld.attributedText = styledText
        } else {
            guard let enteredText = passwordTextFileld.text else {
                return
            }
            let styledText = UIFont.fontStyle(
                font: .regular,
                title: enteredText,
                size: 15,
                textColor: .B2 ?? .black,
                letterSpacing: 3)
            passwordTextFileld.attributedText = styledText
        }
        
    }
}
