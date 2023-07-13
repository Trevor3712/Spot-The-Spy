//
//  VictoryViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/18.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class VictoryViewController: BaseViewController {
    lazy var identityImageView = UIImageView()
    lazy var victoryLabel: UILabel = {
        let victoryLabel = UILabel()
        victoryLabel.backgroundColor = .Y
        victoryLabel.layer.borderWidth = 1
        victoryLabel.layer.borderColor = UIColor.B1?.cgColor
        victoryLabel.layer.cornerRadius = 20
        victoryLabel.clipsToBounds = true
        victoryLabel.textAlignment = .center
        return victoryLabel
    }()
    lazy var backToLobbyButton: BaseButton = {
        let backToLobbyButton = BaseButton()
        backToLobbyButton.setNormal("回到大廳")
        backToLobbyButton.setHighlighted("回到大廳")
        backToLobbyButton.titleLabel?.textAlignment = .center
        backToLobbyButton.addTarget(self, action: #selector(backToLobbyButtonPressed), for: .touchUpInside)
        return backToLobbyButton
    }()
    lazy var normalPromptLabel: UILabel = {
        let normalPromptLabel = UILabel()
        normalPromptLabel.backgroundColor = .white
        normalPromptLabel.layer.borderWidth = 1
        normalPromptLabel.layer.borderColor = UIColor.B1?.cgColor
        normalPromptLabel.layer.cornerRadius = 20
        normalPromptLabel.clipsToBounds = true
        normalPromptLabel.textAlignment = .center
        return normalPromptLabel
    }()
    lazy var spyPromptLabel: UILabel = {
        let spyPromptLabel = UILabel()
        spyPromptLabel.backgroundColor = .white
        spyPromptLabel.layer.borderWidth = 1
        spyPromptLabel.layer.borderColor = UIColor.B1?.cgColor
        spyPromptLabel.layer.cornerRadius = 20
        spyPromptLabel.clipsToBounds = true
        spyPromptLabel.textAlignment = .center
        return spyPromptLabel
    }()
    let dataBase = Firestore.firestore()
    var isSpyWin = true
    let playerIdentity = UserDefaults.standard.string(forKey: "playerIdentity")
    var spyWin: Int?
    var spyLose: Int?
    var normalWin: Int?
    var normalLose: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        whoWins()
        configureLayout()
        getPrompt()
        showPrompt(normalPrompt: "工程師", spyPrompt: "工具人")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let url = Bundle.main.url(forResource: "victory_bgm", withExtension: "wav")
        AudioPlayer.shared.playAudio(from: url!, loop: true)
        getRecords()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AudioPlayer.shared.stopAudio()
    }
    func whoWins() {
        if isSpyWin {
            victoryLabel.attributedText = UIFont.fontStyle(
                font: .boldItalicEN,
                title: "臥底獲勝",
                size: 45,
                textColor: .B2 ?? .black,
                letterSpacing: 15)
            identityImageView.image = .asset(.spyWin)
        } else {
            victoryLabel.attributedText = UIFont.fontStyle(
                font: .boldItalicEN,
                title: "平民獲勝",
                size: 45,
                textColor: .B2 ?? .black,
                letterSpacing: 15)
            identityImageView.image = .asset(.normalWin)
        }
    }
    func getPrompt() {
        let room = self.dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        documentRef.getDocument { (document, error) in
            if let document = document,
               let normalPrompt = document.data()?["normalPrompt"] as? String,
               let spyPrompt = document.data()?["spyPrompt"] as? String {
//                self.showPrompt(normalPrompt: normalPrompt, spyPrompt: spyPrompt)
            } else {
                print("Failed to retrieve player name")
            }
        }
    }
    func showPrompt(normalPrompt: String, spyPrompt: String) {
        self.normalPromptLabel.attributedText = UIFont.fontStyle(
            font: .regular,
            title: "平民題目：\(normalPrompt)",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        self.spyPromptLabel.attributedText = UIFont.fontStyle(
            font: .regular,
            title: "臥底題目：\(spyPrompt)",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
    }
    func configureLayout() {
        [identityImageView, victoryLabel, normalPromptLabel, spyPromptLabel, backToLobbyButton].forEach { view.addSubview($0) }
        self.victoryLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.width.equalTo(300)
            make.height.equalTo(80)
        }
        identityImageView.snp.makeConstraints { make in
            make.bottom.equalTo(victoryLabel.snp.top).offset(-80)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
        normalPromptLabel.snp.makeConstraints { make in
            make.top.equalTo(victoryLabel.snp.bottom).offset(30)
            make.centerX.equalTo(view)
            make.width.equalTo(300)
            make.height.equalTo(40)
        }
        spyPromptLabel.snp.makeConstraints { make in
            make.top.equalTo(normalPromptLabel.snp.bottom).offset(10)
            make.centerX.equalTo(view)
            make.width.equalTo(300)
            make.height.equalTo(40)
        }
        backToLobbyButton.snp.makeConstraints { make in
            make.top.equalTo(spyPromptLabel.snp.bottom).offset(100)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
    }
    @objc func backToLobbyButtonPressed() {
        playSeAudio(from: clickUrl!)
        vibrate()
        if let targetViewController = navigationController?.viewControllers[1] {
            navigationController?.popToViewController(targetViewController, animated: true)
            deleteGameData()
            updateRecords()
        }
    }
    func deleteGameData() {
        let room = dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        documentRef.delete { error in
            if let error = error {
                print("Delete error：\(error.localizedDescription)")
            } else {
                print("Delete successfully")
            }
        }
    }
    func getRecords() {
        let room = dataBase.collection("Users")
        guard let userId = Auth.auth().currentUser?.email else {
            return
        }
        let documentRef = room.document(userId)
        documentRef.getDocument { (document, error) in
            guard let document = document else {
                return
            }
            if let normalWin = document.data()?["normalWin"] as? String {
                self.normalWin = Int(normalWin)
            }
            if let normalLose = document.data()?["normalLose"] as? String {
                self.normalLose = Int(normalLose)
            }
            if let spyWin = document.data()?["spyWin"] as? String {
                self.spyWin = Int(spyWin)
            }
            if let spyLose = document.data()?["spyLose"] as? String {
                self.spyLose = Int(spyLose)
            }
        }
    }
    func updateRecords() {
        if isSpyWin {
            if playerIdentity == "臥底" {
                updateRecord("spyWin", spyWin ?? 0)
            } else {
                updateRecord("normalLose", normalLose ?? 0)
            }
        } else {
            if playerIdentity == "平民" {
                updateRecord("normalWin", normalWin ?? 0)
            } else {
                updateRecord("spyLose", spyLose ?? 0)
            }
        }
    }
    func updateRecord(_ string: String, _ int: Int) {
        let room = dataBase.collection("Users")
        guard let userId = Auth.auth().currentUser?.email else {
            return
        }
        let documentRef = room.document(userId)
        let data: [String: Any] = [
            string: String(int + 1)
        ]
        documentRef.updateData(data) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document updated successfully")
            }
        }
    }
}
