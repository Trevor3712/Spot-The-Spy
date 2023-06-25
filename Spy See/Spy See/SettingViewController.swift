//
//  SettingViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/15.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import CryptoKit

class SettingViewController: BaseViewController {
    lazy var logoImage: UIImageView = {
        let logoImage = UIImageView()
        logoImage.image = .asset(.spy)
        return logoImage
    }()
    lazy var playersCountLabel: UILabel = {
        let playersCountLabel = UILabel()
        playersCountLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "玩家人數",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        return playersCountLabel
    }()
    lazy var playersCountTextFileld: BaseTextField = {
        let playersCountTextFileld = BaseTextField()
        playersCountTextFileld.placeholder = "請選擇人數"
        playersCountTextFileld.textAlignment = .center
        playersCountTextFileld.inputView = playersCountPickerView
        return playersCountTextFileld
    }()
    lazy var playersCountPickerView: UIPickerView = {
        let playersCountPickerView = UIPickerView()
        playersCountPickerView.delegate = self
        playersCountPickerView.dataSource = self
        playersCountPickerView.tag = 1
        return playersCountPickerView
    }()
    lazy var spysCountLabel: UILabel = {
        let spysCountLabel = UILabel()
        spysCountLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "臥底人數",
            size: 20,
            textColor: .B4 ?? .black,
            letterSpacing: 5)
        return spysCountLabel
    }()
    lazy var spysCountTextFileld: BaseTextField = {
        let spysCountTextFileld = BaseTextField()
        spysCountTextFileld.placeholder = "請選擇人數"
        spysCountTextFileld.textAlignment = .center
        spysCountTextFileld.inputView = spysCountPickerView
        return spysCountTextFileld
    }()
    lazy var spysCountPickerView: UIPickerView = {
        let spysCountPickerView = UIPickerView()
        spysCountPickerView.delegate = self
        spysCountPickerView.dataSource = self
        spysCountPickerView.tag = 2
        return spysCountPickerView
    }()
    lazy var invitationButton: BaseButton = {
        let invitationButton = BaseButton()
        invitationButton.setAttributedTitle(UIFont.fontStyle(
            font: .semibold,
            title: "取得邀請碼",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5), for: .normal)
        invitationButton.titleLabel?.textAlignment = .center
        invitationButton.addTarget(self, action: #selector(invitationButtonPressed), for: .touchUpInside)
        return invitationButton
    }()
    let playersCount = [3, 4, 5, 6, 7, 8, 9, 10]
    let spysCount = [1, 2, 3]
    let dataBase = Firestore.firestore()
    var promptArray: [String] = []
    var identityArray: [String] = []
    var shuffledIndices: [Int] = []
    var choosedPrompt: ([String], [String]) = ([], [])
    override func viewDidLoad() {
        super.viewDidLoad()
        [
            logoImage,
            playersCountLabel, playersCountTextFileld,
            spysCountLabel, spysCountTextFileld,
            invitationButton].forEach { view.addSubview($0) }
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
    @objc func invitationButtonPressed(_ sender: UIButton) {
        let room = dataBase.collection("Rooms")
        let roomId = generateRoomId()
        UserDefaults.standard.setValue(roomId, forKey: "roomId")
        let documentRef = room.document(roomId)
        guard let email = Auth.auth().currentUser?.email else {
            print("Email is missing")
            return
        }
        let prompts = generatePromptArray()
        let identities = generateIdentityArray()
        let data: [String: Any] = [
            "prompts": prompts,
            "identities": identities,
            "player": [email],
            "playerNumber": playersCountTextFileld.text ?? ""
        ]
        documentRef.setData(data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
                UserDefaults.standard.removeObject(forKey: "playerPrompt")
                UserDefaults.standard.removeObject(forKey: "hostPrompt")
                UserDefaults.standard.setValue(self.promptArray[0], forKey: "hostPrompt")
                let inviteVC = InviteViewController()
                self.navigationController?.pushViewController(inviteVC, animated: true)
            }
        }
    }
    func generateRoomId() -> String {
        let inviteCodeLength = 4
        let fullCode = UUID().uuidString
        let hash = SHA256.hash(data: fullCode.data(using: .utf8)!)
        let hashedString = hash.compactMap { String(format: "%02x", $0) }.joined()
        let roomId = String(hashedString.prefix(inviteCodeLength))
        return roomId
    }
    func generatePromptArray() -> [String] {
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
    func generateIdentityArray() -> [String] {
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
