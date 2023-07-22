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
    private lazy var logoImage: UIImageView = {
        let logoImage = UIImageView()
        logoImage.image = .asset(.spy)
        return logoImage
    }()
    private lazy var titleContainerView = UIView()
    private lazy var labelCN1: UILabel = {
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
    private lazy var labelCN2: UILabel = {
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
    private lazy var labelEN1: UILabel = {
        let labelEN1 = UILabel()
        labelEN1.attributedText = UIFont.fontStyle(
            font: .boldItalicEN,
            title: "SPOT",
            size: 45,
            textColor: .B2 ?? .black,
            letterSpacing: 10,
            obliqueness: 0.1)
        return labelEN1
    }()
    private lazy var labelEN2: UILabel = {
        let labelEN2 = UILabel()
        labelEN2.attributedText = UIFont.fontStyle(
            font: .boldItalicEN,
            title: "THE",
            size: 25,
            textColor: .B2 ?? .black,
            letterSpacing: 10,
            obliqueness: 0.1)
        return labelEN2
    }()
    private lazy var labelEN3: UILabel = {
        let labelEN3 = UILabel()
        labelEN3.attributedText = UIFont.fontStyle(
            font: .boldItalicEN,
            title: "SPY",
            size: 45,
            textColor: .B4 ?? .black,
            letterSpacing: 10,
            obliqueness: 0.1)
        return labelEN3
    }()
    private lazy var accountContainerView = UIView()
    private lazy var accountTextField: BaseTextField = {
        let accountTextField = BaseTextField()
        accountTextField.placeholder = "請輸入帳號"
        accountTextField.keyboardType = .emailAddress
        accountTextField.autocorrectionType = .no
        accountTextField.delegate = self
        accountTextField.tag = 1
        return accountTextField
    }()
    private lazy var passwordTextField: BaseTextField = {
        let passwordTextField = BaseTextField()
        passwordTextField.placeholder = "請輸入密碼"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocorrectionType = .no
        passwordTextField.delegate = self
        passwordTextField.tag = 2
        return passwordTextField
    }()
    private lazy var loginButton: BaseButton = {
        let loginButton = BaseButton()
        loginButton.setNormal("登入")
        loginButton.setHighlighted("登入")
        loginButton.setTitleColor(.B4, for: .highlighted)
        loginButton.addTarget(self, action: #selector(logInButtonPressed), for: .touchUpInside)
        return loginButton
    }()
    private lazy var signupButton: BaseButton = {
        let signupButton = BaseButton()
        signupButton.setNormal("註冊")
        signupButton.setHighlighted("註冊")
        signupButton.addTarget(self, action: #selector(signupButtonPressed), for: .touchUpInside)
        return signupButton
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        [logoImage, titleContainerView, accountContainerView].forEach { view.addSubview($0) }
        [labelCN1, labelCN2, labelEN1, labelEN2, labelEN3].forEach { titleContainerView.addSubview($0) }
        [accountTextField, passwordTextField].forEach { accountContainerView.addSubview($0) }
        [loginButton, signupButton].forEach { accountContainerView.addSubview($0) }
        configureLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let url = Bundle.main.url(forResource: "main_bgm", withExtension: "wav")
        guard let url = url else {
            return
        }
        if AudioPlayer.shared.audioPlayer?.isPlaying == nil {
            AudioPlayer.shared.playAudio(from: url, loop: true)
        }
        accountTextField.text = ""
        passwordTextField.text = ""
    }
    private func configureLayout() {
        logoImage.snp.makeConstraints { make in
            make.bottom.equalTo(titleContainerView.snp.top).offset(-40)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
        titleContainerView.snp.makeConstraints { make in
            make.centerX.centerY.left.right.equalTo(view)
            make.height.equalTo(200)
        }
        labelCN1.snp.makeConstraints { make in
            make.top.equalTo(titleContainerView)
            make.right.equalTo(titleContainerView.snp.centerX).offset(12)
        }
        labelCN2.snp.makeConstraints { make in
            make.top.equalTo(labelCN1.snp.bottom)
            make.left.equalTo(titleContainerView.snp.centerX).offset(24)
        }
        labelEN1.snp.makeConstraints { make in
            make.top.equalTo(labelCN1.snp.bottom)
            make.right.equalTo(titleContainerView.snp.centerX).offset(-12)
        }
        labelEN2.snp.makeConstraints { make in
            make.top.equalTo(labelEN1.snp.bottom)
            make.right.equalTo(titleContainerView.snp.centerX).offset(-36)
        }
        labelEN3.snp.makeConstraints { make in
            make.top.equalTo(labelCN2.snp.bottom)
            make.left.equalTo(titleContainerView.snp.centerX)
        }
        accountContainerView.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.top.lessThanOrEqualTo(titleContainerView.snp.bottom).offset(50)
            make.height.equalTo(200)
        }
        accountTextField.snp.makeConstraints { make in
            make.top.equalTo(accountContainerView)
            make.centerX.equalTo(view)
            make.width.equalTo(260)
            make.height.equalTo(40)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(accountTextField.snp.bottom).offset(30)
            make.centerX.equalTo(view)
            make.width.equalTo(260)
            make.height.equalTo(40)
        }
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.left.equalTo(passwordTextField)
            make.width.equalTo(115)
            make.height.equalTo(40)
        }
        signupButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.right.equalTo(passwordTextField)
            make.width.equalTo(115)
            make.height.equalTo(40)
        }
    }
    @objc private func logInButtonPressed(_ sender: UIButton) {
        playSeAudio()
        vibrate()
        Auth.auth().signIn(
            withEmail: accountTextField.text ?? "",
            password: passwordTextField.text ?? "") { _, error in
            guard error == nil else {
                let alertVC = AlertViewController()
                let alert = alertVC.showAlert(title: "登入錯誤", message: error?.localizedDescription ?? "")
                self.present(alert, animated: true)
                print(error?.localizedDescription ?? "")
                return
            }
            guard let tabBarController = self.storyboard?.instantiateViewController(
                withIdentifier: "TabBarController") as? UITabBarController else {
                return
            }
            self.navigationController?.pushViewController(tabBarController, animated: true)
            UserDefaults.standard.setValue(Auth.auth().currentUser?.email, forKey: "userEmail")
        }
    }
    @objc private func signupButtonPressed() {
        playSeAudio()
        vibrate()
        let signupVC = SignupViewController()
        navigationController?.pushViewController(signupVC, animated: true)
    }
}
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let editingUrl = editingUrl else {
            return
        }
        playSeAudio(from: editingUrl)
        vibrate()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            guard let enteredText = accountTextField.text else {
                return
            }
            let styledText = UIFont.fontStyle(
                font: .regular,
                title: enteredText,
                size: 15,
                textColor: .B2 ?? .black,
                letterSpacing: 3)
            accountTextField.attributedText = styledText
        } else {
            guard let enteredText = passwordTextField.text else {
                return
            }
            let styledText = UIFont.fontStyle(
                font: .regular,
                title: enteredText,
                size: 15,
                textColor: .B2 ?? .black,
                letterSpacing: 3)
            passwordTextField.attributedText = styledText
        }
    }
}
