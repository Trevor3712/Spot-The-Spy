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
        nameTextField.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "超帥的暱稱",
            size: 40,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = UIColor.B1?.cgColor
        nameTextField.layer.cornerRadius = 20
        nameTextField.clipsToBounds = true
        nameTextField.textAlignment = .center
//        nameTextField.adjustsFontSizeToFitWidth = true
//        nameTextField.minimumFontSize = 20
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
    override func viewDidLoad() {
        super.viewDidLoad()
        [nameTextField, nameLabel, infoLabel, deleteButton].forEach { view.addSubview($0) }
        nameTextField.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.centerY).offset(-50)
            make.centerX.equalTo(view)
            make.width.equalTo(300)
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
            size: 40,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        nameTextField.attributedText = styledText
    }
}
