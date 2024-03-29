//
//  LobbyViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/15.
//

import UIKit
import FirebaseAuth

class LobbyViewController: BaseViewController {
    private lazy var logoImage: UIImageView = {
        let logoImage = UIImageView()
        logoImage.image = .asset(.spy)
        return logoImage
    }()
    private lazy var createRoomButton: BaseButton = {
        let createRoomButton = BaseButton()
        createRoomButton.setNormal("建立遊戲")
        createRoomButton.setHighlighted("建立遊戲")
        createRoomButton.addTarget(self, action: #selector(createRoomButtonPressed), for: .touchUpInside)
        return createRoomButton
    }()
    private lazy var joinLabel: UILabel = {
        let joinLabel = UILabel()
        joinLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "加入遊戲",
            size: 20,
            textColor: .B4 ?? .black,
            letterSpacing: 10)
        return joinLabel
    }()
    lazy var invitationTextFileld: BaseTextField = {
        let invitationTextFileld = BaseTextField()
        invitationTextFileld.placeholder = "請輸入邀請碼"
        invitationTextFileld.keyboardType = .asciiCapable
        invitationTextFileld.autocorrectionType = .no
        invitationTextFileld.textAlignment = .center
        invitationTextFileld.delegate = self
        return invitationTextFileld
    }()
    private lazy var goButton: BaseButton = {
        let goButton = BaseButton()
        goButton.setNormal("GO!")
        goButton.setHighlighted("GO!")
        goButton.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
        return goButton
    }()
    private var userName: String?
    private let alertVC = AlertViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationItem.hidesBackButton = true
        [logoImage, createRoomButton, joinLabel].forEach { view.addSubview($0) }
        [invitationTextFileld, goButton].forEach { view.addSubview($0) }
        logoImage.snp.makeConstraints { make in
            make.bottom.equalTo(createRoomButton.snp.top).offset(-30)
            make.left.equalTo(view).offset(50)
            make.width.equalTo(150)
            make.height.equalTo(150)
        }
        createRoomButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.centerY).offset(-50)
            make.centerX.equalTo(logoImage)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        joinLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.centerY).offset(50)
            make.right.equalTo(view).offset(-55)
        }
        invitationTextFileld.snp.makeConstraints { make in
            make.top.equalTo(joinLabel.snp.bottom).offset(20)
            make.centerX.equalTo(joinLabel)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        goButton.snp.makeConstraints { make in
            make.top.equalTo(invitationTextFileld.snp.bottom).offset(30)
            make.centerX.equalTo(joinLabel)
            make.width.equalTo(75)
            make.height.equalTo(40)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserDefaults.standard.setValue(Auth.auth().currentUser?.email, forKey: UDConstants.userEmail)
        let url = Bundle.main.url(forResource: SoundConstant.main, withExtension: SoundConstant.wav)
        guard let url = url else {
            return
        }
        if AudioPlayer.shared.audioPlayer?.isPlaying == nil {
            AudioPlayer.shared.playAudio(from: url, loop: true)
        }
        getUserName()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.hidesBackButton = false
    }
    @objc private func createRoomButtonPressed() {
        playSeAudio()
        vibrate()
        let settingVC = SettingViewController()
        navigationController?.pushViewController(settingVC, animated: true)
    }
    @objc private func goButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        playSeAudio()
        vibrate()
        guard let invitationText = invitationTextFileld.text, !invitationText.isEmpty, invitationText != "請輸入邀請碼" else {
            let alert = alertVC.showAlert(title: "輸入錯誤", message: "請輸入邀請碼")
            present(alert, animated: true)
            sender.isEnabled = true
            return
        }
        UserDefaults.standard.setValue(invitationText, forKey: UDConstants.roomId)
        FirestoreManager.shared.getDocument { [weak self] result in
            guard let self = self else { return }
            sender.isEnabled = true
            switch result {
            case .success(let document):
                guard let document = document else {
                    return
                }
                if var players = document.data()?[FirestoreConstans.player] as? [String] {
                    guard let name = userName else {
                        print("Name is missing")
                        return
                    }
                    guard !players.contains(name) else {
                        return
                    }
                    players.append(name)
                    // 計算玩家的index
                    let playerIndex = players.count - 1
                    setPlayer(player: players, playerIndex: playerIndex)
                    let waitingVC = WaitingViewController()
                    self.navigationController?.pushViewController(waitingVC, animated: true)
                }
            case .failure(let error):
                let alert = self.alertVC.showAlert(title: "輸入錯誤", message: "查無此邀請碼")
                present(alert, animated: true)
                print("Document does not exist or there was an error: \(error.localizedDescription )")
            }
        }
    }
    private func setPlayer(player: [String], playerIndex: Int) {
        let data: [String: Any] = [
            FirestoreConstans.player: player,
            FirestoreConstans.playerIndex: playerIndex // 存入玩家的index
        ]
        FirestoreManager.shared.setData(data: data, merge: true) {
            self.getUserPrompt()
            self.invitationTextFileld.text = ""
        }
    }
    private func getUserPrompt() {
        FirestoreManager.shared.getDocument { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let document):
                guard let document = document else {
                    return
                }
                if let playerIndex = document.data()?[FirestoreConstans.playerIndex] as? Int {
                    if let prompts = document.data()?[FirestoreConstans.prompts] as? [String] {
                        if let identities = document.data()?[FirestoreConstans.identities] as? [String] {
                            handlePlayerIndex(playerIndex, prompts, identities)
                            UserDefaults.standard.setValue(self.userName, forKey: UDConstants.userName)
                        }
                    }
                }
            case .failure(let error):
                print("Error getting document:\(error)")
            }
        }
    }
    private func handlePlayerIndex(_ playerIndex: Int, _ prompts: [String], _ identities: [String]) {
        guard playerIndex >= 0 && playerIndex < prompts.count else {
            print("Invalid player index")
            return
        }
        let playerIdentity = identities[playerIndex]
        UserDefaults.standard.setValue(playerIdentity, forKey: UDConstants.playerIdentity)
        let selectedPrompt = prompts[playerIndex]
        UserDefaults.standard.removeObject(forKey: UDConstants.hostPrompt)
        UserDefaults.standard.setValue(selectedPrompt, forKey: UDConstants.playerPrompt)
    }
    private func getUserName() {
        FirestoreManager.shared.getDocument(
            collection: FirestoreConstans.users,
            key: FirestoreConstans.userEmail) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let document):
                guard let document = document else {
                    return
                }
                if let name = document.data()?[FirestoreConstans.name] as? String {
                    userName = name
                }
            case .failure(let error):
                print("Error getting document:\(error)")
            }
        }
    }
}
extension LobbyViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let editingUrl = editingUrl else {
            return
        }
        playSeAudio(from: editingUrl)
        vibrate()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let enteredText = invitationTextFileld.text else {
            return
        }
        let styledText = UIFont.fontStyle(
            font: .regular,
            title: enteredText,
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 3)
        invitationTextFileld.attributedText = styledText
    }
}
