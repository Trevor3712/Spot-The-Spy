//
//  VictoryViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/18.
//

import UIKit
import FirebaseAuth

class VictoryViewController: BaseViewController {
    private lazy var identityImageView = UIImageView()
    private lazy var victoryLabel: UILabel = {
        let victoryLabel = UILabel()
        victoryLabel.backgroundColor = .Y
        victoryLabel.layer.borderWidth = 1
        victoryLabel.layer.borderColor = UIColor.B1?.cgColor
        victoryLabel.layer.cornerRadius = 20
        victoryLabel.clipsToBounds = true
        victoryLabel.textAlignment = .center
        return victoryLabel
    }()
    private lazy var backToLobbyButton: BaseButton = {
        let backToLobbyButton = BaseButton()
        backToLobbyButton.setNormal("回到大廳")
        backToLobbyButton.setHighlighted("回到大廳")
        backToLobbyButton.titleLabel?.textAlignment = .center
        backToLobbyButton.addTarget(self, action: #selector(backToLobbyButtonPressed), for: .touchUpInside)
        return backToLobbyButton
    }()
    private lazy var normalPromptLabel: UILabel = {
        let normalPromptLabel = UILabel()
        normalPromptLabel.backgroundColor = .white
        normalPromptLabel.layer.borderWidth = 1
        normalPromptLabel.layer.borderColor = UIColor.B1?.cgColor
        normalPromptLabel.layer.cornerRadius = 20
        normalPromptLabel.clipsToBounds = true
        normalPromptLabel.textAlignment = .center
        return normalPromptLabel
    }()
    private lazy var spyPromptLabel: UILabel = {
        let spyPromptLabel = UILabel()
        spyPromptLabel.backgroundColor = .white
        spyPromptLabel.layer.borderWidth = 1
        spyPromptLabel.layer.borderColor = UIColor.B1?.cgColor
        spyPromptLabel.layer.cornerRadius = 20
        spyPromptLabel.clipsToBounds = true
        spyPromptLabel.textAlignment = .center
        return spyPromptLabel
    }()
    var isSpyWin = true
    private let playerIdentity = UserDefaults.standard.string(forKey: "playerIdentity")
    private var spyWin: Int?
    private var spyLose: Int?
    private var normalWin: Int?
    private var normalLose: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        whoWins()
        configureLayout()
        getPrompt()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let url = Bundle.main.url(forResource: "victory_bgm", withExtension: "wav") {
            AudioPlayer.shared.playAudio(from: url, loop: true)
        }
        getRecords()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AudioPlayer.shared.stopAudio()
    }
    private func whoWins() {
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
    private func getPrompt() {
        FirestoreManager.shared.getDocument { result in
            switch result {
            case.success(let document):
                guard let document = document else {
                    return
                }
                if let normalPrompt = document.data()?["normalPrompt"] as? String {
                    if let spyPrompt = document.data()?["spyPrompt"] as? String {
                        self.showPrompt(normalPrompt: normalPrompt, spyPrompt: spyPrompt)
                    }
                }
            case .failure(let error):
                print("Error getting document:\(error)")
            }
        }
    }
    private func showPrompt(normalPrompt: String, spyPrompt: String) {
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
    private func configureLayout() {
        [identityImageView, victoryLabel].forEach { view.addSubview($0) }
        [normalPromptLabel, spyPromptLabel, backToLobbyButton].forEach { view.addSubview($0) }
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
    @objc private func backToLobbyButtonPressed() {
        playSeAudio()
        vibrate()
        if let targetViewController = navigationController?.viewControllers[1] {
            navigationController?.popToViewController(targetViewController, animated: true)
            deleteGameData()
            updateRecords()
        }
    }
    private func deleteGameData() {
        FirestoreManager.shared.delete()
    }
    private func getRecords() {
        FirestoreManager.shared.getDocument(collection: "Users", key: "userEmail") { result in
            switch result {
            case .success(let document):
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
            case .failure(let error):
                print("Error getting document:\(error)")
            }
        }
    }
    private func updateRecords() {
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
    private func updateRecord(_ string: String, _ int: Int) {
        let data: [String: Any] = [
            string: String(int + 1)
        ]
        FirestoreManager.shared.updateData(collection: "Users", key: "userEmail", data: data)
    }
}
