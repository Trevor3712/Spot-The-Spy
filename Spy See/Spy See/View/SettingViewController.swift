//
//  SettingViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/15.
//

import UIKit
import FirebaseAuth
import CryptoKit

class SettingViewController: BaseViewController {
    private lazy var logoImage: UIImageView = {
        let logoImage = UIImageView()
        logoImage.image = .asset(.spy)
        return logoImage
    }()
    private lazy var playersCountLabel: UILabel = {
        let playersCountLabel = UILabel()
        playersCountLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "玩家人數",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        return playersCountLabel
    }()
    private lazy var playersCountTextFileld: BaseTextField = {
        let playersCountTextFileld = BaseTextField()
        playersCountTextFileld.placeholder = "請選擇人數"
        playersCountTextFileld.textAlignment = .center
        playersCountTextFileld.inputView = playersCountPickerView
        playersCountTextFileld.delegate = self
        playersCountTextFileld.tag = 1
        return playersCountTextFileld
    }()
    private lazy var playersCountPickerView: UIPickerView = {
        let playersCountPickerView = UIPickerView()
        playersCountPickerView.delegate = self
        playersCountPickerView.dataSource = self
        playersCountPickerView.tag = 1
        return playersCountPickerView
    }()
    private lazy var spysCountLabel: UILabel = {
        let spysCountLabel = UILabel()
        spysCountLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "臥底人數",
            size: 20,
            textColor: .B4 ?? .black,
            letterSpacing: 5)
        return spysCountLabel
    }()
    private lazy var spysCountTextFileld: BaseTextField = {
        let spysCountTextFileld = BaseTextField()
        spysCountTextFileld.placeholder = "請選擇人數"
        spysCountTextFileld.textAlignment = .center
        spysCountTextFileld.inputView = spysCountPickerView
        spysCountTextFileld.delegate = self
        spysCountTextFileld.tag = 2
        return spysCountTextFileld
    }()
    private lazy var spysCountPickerView: UIPickerView = {
        let spysCountPickerView = UIPickerView()
        spysCountPickerView.delegate = self
        spysCountPickerView.dataSource = self
        spysCountPickerView.tag = 2
        return spysCountPickerView
    }()
    private lazy var invitationButton: BaseButton = {
        let invitationButton = BaseButton()
        invitationButton.setNormal("取得邀請碼")
        invitationButton.setHighlighted("取得邀請碼")
        invitationButton.addTarget(self, action: #selector(invitationButtonPressed), for: .touchUpInside)
        return invitationButton
    }()
    private let playersCount = [3, 4, 5, 6, 7, 8, 9, 10]
    private let spysCount = [1, 2, 3]
    private var promptArray: [String] = []
    private var identityArray: [String] = []
    private var shuffledIndices: [Int] = []
    private var choosedPrompt: ([String], [String]) = ([], [])
    private var userName: String?
    private let alertVC = AlertViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonPressed))
        backButton.tintColor = .B1
        navigationItem.leftBarButtonItem = backButton
        [
            logoImage,
            playersCountLabel, playersCountTextFileld,
            spysCountLabel, spysCountTextFileld,
            invitationButton
        ].forEach { view.addSubview($0) }
        logoImage.snp.makeConstraints { make in
            make.top.equalTo(view).offset(200)
            make.left.equalTo(view).offset(50)
            make.width.equalTo(130)
            make.height.equalTo(130)
        }
        playersCountLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImage.snp.bottom).offset(20)
            make.centerX.equalTo(logoImage)
        }
        playersCountTextFileld.snp.makeConstraints { make in
            make.top.equalTo(playersCountLabel.snp.bottom).offset(10)
            make.centerX.equalTo(logoImage)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        spysCountLabel.snp.makeConstraints { make in
            make.top.equalTo(playersCountTextFileld.snp.bottom).offset(75)
            make.right.equalTo(view).offset(-70)
        }
        spysCountTextFileld.snp.makeConstraints { make in
            make.top.equalTo(spysCountLabel.snp.bottom).offset(10)
            make.centerX.equalTo(spysCountLabel)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        invitationButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-130)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserName()
    }
    @objc private func invitationButtonPressed(_ sender: UIButton) {
        playSeAudio()
        vibrate()
        guard let playersCount = playersCountTextFileld.text, !playersCount.isEmpty else {
            settingErrorAlert()
            return
        }
        guard let spysCount = spysCountTextFileld.text, !spysCount.isEmpty else {
            settingErrorAlert()
            return
        }
        let roomId = generateRoomId()
        UserDefaults.standard.setValue(roomId, forKey: "roomId")
        guard let name = self.userName else {
            return
        }
        let prompts = generatePromptArray()
        let identities = generateIdentityArray()
        let data: [String: Any] = [
            FirestoreConstans.prompts: prompts,
            FirestoreConstans.identities: identities,
            FirestoreConstans.player: [name],
            FirestoreConstans.playerNumber: playersCountTextFileld.text ?? "",
            FirestoreConstans.normalPrompt: "\(choosedPrompt.0[1])",
            FirestoreConstans.spyPrompt: "\(choosedPrompt.1[1])"
        ]
        FirestoreManager.shared.setData(data: data) { [weak self] in
            guard let self = self else { return }
            updateUserDefaults()
            let inviteVC = InviteViewController()
            navigationController?.pushViewController(inviteVC, animated: true)
        }
    }
    private func generateRoomId() -> String {
        let inviteCodeLength = 4
        let fullCode = UUID().uuidString
        if let data = fullCode.data(using: .utf8) {
            let hash = SHA256.hash(data: data)
            let hashedString = hash.compactMap { String(format: "%02x", $0) }.joined()
            let roomId = String(hashedString.prefix(inviteCodeLength))
            return roomId
        } else {
            return "0000"
        }
    }
    private func generatePromptArray() -> [String] {
        promptArray = []
        choosedPrompt = prompt.randomElement() ?? ([""], [""])
        for _ in 0...(Int(playersCountTextFileld.text ?? "") ?? 0) - (Int(spysCountTextFileld.text ?? "") ?? 0) - 1 {
            promptArray.append(choosedPrompt.0[1])
        }
        for _ in 0...(Int(spysCountTextFileld.text ?? "") ?? 0) - 1 {
            promptArray.append(choosedPrompt.1[1])
        }
        shuffledIndices = Array(promptArray.indices).shuffled()
        promptArray = shuffledIndices.map { promptArray[$0] }
        return promptArray
    }
    private func generateIdentityArray() -> [String] {
        identityArray = []
        for _ in 0...(Int(playersCountTextFileld.text ?? "") ?? 0) - (Int(spysCountTextFileld.text ?? "") ?? 0) - 1 {
            identityArray.append(choosedPrompt.0[0])
        }
        for _ in 0...(Int(spysCountTextFileld.text ?? "") ?? 0) - 1 {
            identityArray.append(choosedPrompt.1[0])
        }
        identityArray = shuffledIndices.map { identityArray[$0] }
        return identityArray
    }
    private func getUserName() {
        FirestoreManager.shared.getDocument(collection: "Users", key: "userEmail") { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let document):
                guard let document = document else {
                    return
                }
                if let name = document.data()?["name"] as? String {
                    userName = name
                }
            case .failure(let error):
                print("Error getting document:\(error)")
            }
        }
    }
    @objc private func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    private func updateUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "playerPrompt")
        UserDefaults.standard.setValue(self.promptArray[0], forKey: "hostPrompt")
        UserDefaults.standard.setValue(self.userName, forKey: "userName")
        UserDefaults.standard.set(self.promptArray[0], forKey: "playerIdentity")
    }
    private func settingErrorAlert() {
        let alert = alertVC.showAlert(title: "設定錯誤", message: "請選擇玩家人數、臥底人數")
        present(alert, animated: true, completion: nil)
    }
}
extension SettingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return playersCount.count
        } else {
            return spysCount.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return String(playersCount[row])
        } else {
            return String(spysCount[row])
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            playersCountTextFileld.attributedText = UIFont.fontStyle(
                font: .regular,
                title: "\(String(playersCount[row]))",
                size: 20,
                textColor: .B2 ?? .black,
                letterSpacing: 5)
        } else {
            spysCountTextFileld.attributedText = UIFont.fontStyle(
                font: .regular,
                title: "\(String(spysCount[row]))",
                size: 20,
                textColor: .B2 ?? .black,
                letterSpacing: 5)
        }
    }
}
extension SettingViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let editingUrl = editingUrl else {
            return
        }
        playSeAudio(from: editingUrl)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            // swiftlint:disable empty_string
            if playersCountTextFileld.text == "" {
                playersCountTextFileld.attributedText = UIFont.fontStyle(
                    font: .regular,
                    title: "\(String(playersCount[0]))",
                    size: 20,
                    textColor: .B2 ?? .black,
                    letterSpacing: 5)
            }
        } else {
            if spysCountTextFileld.text == "" {
                spysCountTextFileld.attributedText = UIFont.fontStyle(
                    font: .regular,
                    title: "\(String(spysCount[0]))",
                    size: 20,
                    textColor: .B2 ?? .black,
                    letterSpacing: 5)
            }
            // swiftlint:enable empty_string
        }
    }
}
