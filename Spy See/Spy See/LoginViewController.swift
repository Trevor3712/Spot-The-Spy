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
            letterSpacing: 15)
        return labelCN1
    }()
    lazy var labelCN2: UILabel = {
        let labelCN2 = UILabel()
        labelCN2.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "臥底",
            size: 50,
            textColor: .B4 ?? .black,
            letterSpacing: 15)
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
        return accountTextFileld
    }()
    lazy var passwordTextFileld: BaseTextField = {
        let passwordTextFileld = BaseTextField()
        passwordTextFileld.placeholder = "請輸入密碼"
        return passwordTextFileld
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        [logoImage, labelCN1, labelCN2, labelEN1, labelEN2, labelEN3, accountTextFileld, passwordTextFileld].forEach { view.addSubview($0) }
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
//        accountTextFileld.snp.makeConstraints { make in
//            make.top.equalTo(view).offset(400)
//            make.centerX.equalTo(view)
//            make.width.equalTo(200)
//            make.height.equalTo(40)
//        }
//        passwordTextFileld.snp.makeConstraints { make in
//            make.top.equalTo(accountTextFileld.snp.bottom).offset(40)
//            make.centerX.equalTo(view)
//            make.width.equalTo(200)
//            make.height.equalTo(40)
//        }
    }
//    @IBAction func logIn(_ sender: UIButton) {
//        Auth.auth().signIn(withEmail: account.text ?? "", password: password.text ?? "") { _, error in
//            guard error == nil else {
//                print(error?.localizedDescription ?? "")
//                return
//            }
//            print("\(self.account.text ?? "") log in")
//            let lobbyVC = LobbyViewController()
//            self.navigationController?.pushViewController(lobbyVC, animated: true)
//        }
//    }
}
