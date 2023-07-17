//
//  PassPromptViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/16.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PassPromptViewController: BaseViewController {
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "你的題目",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        return titleLabel
    }()
    lazy var promotLabel: UILabel = {
        let promotLabel = UILabel()
        promotLabel.backgroundColor = .white
        promotLabel.layer.borderWidth = 1
        promotLabel.layer.borderColor = UIColor.B1?.cgColor
        promotLabel.layer.cornerRadius = 20
        promotLabel.clipsToBounds = true
        promotLabel.textAlignment = .center
        return promotLabel
    }()
    lazy var readyButton: BaseButton = {
        let readyButton = BaseButton()
        readyButton.setNormal("我記住了")
        readyButton.setHighlighted("我記住了")
        readyButton.titleLabel?.textAlignment = .center
        readyButton.addTarget(self, action: #selector(readyButtonPressed), for: .touchUpInside)
        return readyButton
    }()
    var playerPrompt: String?
    var readyPlayers: [String] = []
    var playerNumber: Int?
    var documentListener: ListenerRegistration?
    override func viewDidLoad() {
        super.viewDidLoad()
        [titleLabel, promotLabel, readyButton].forEach { view.addSubview($0) }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            make.centerX.equalTo(view)
        }
        promotLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel).offset(100)
            make.centerX.equalTo(view)
            make.width.equalTo(300)
            make.height.equalTo(80)
        }
        readyButton.snp.makeConstraints { make in
            make.top.equalTo(promotLabel.snp.bottom).offset(100)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let playerPrompt = UserDefaults.standard.string(forKey: "playerPrompt")
            let hostPrompt = UserDefaults.standard.string(forKey: "hostPrompt")
            if playerPrompt != nil {
                self.promotLabel.attributedText = UIFont.fontStyle(
                    font: .semibold,
                    title: playerPrompt ?? "",
                    size: 40,
                    textColor: .B2 ?? .black,
                    letterSpacing: 15)
            } else {
                self.promotLabel.attributedText = UIFont.fontStyle(
                    font: .semibold,
                    title: hostPrompt ?? "",
                    size: 40,
                    textColor: .B2 ?? .black,
                    letterSpacing: 15)
            }
        }
        loadReadyPlayers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AudioPlayer.shared.stopAudio()
        documentListener?.remove()
    }
    @objc func readyButtonPressed() {
        playSeAudio()
        vibrate()
        guard let email = Auth.auth().currentUser?.email else {
            print("Email is missing")
            return
        }
        FirestoreManager.shared.getDocument { result in
            switch result {
            case .success(let document):
                guard let document = document else {
                    return
                }
                var playersReady = document.data()?["playersReady"] as? [String] ?? []
                if !playersReady.contains(email) {
                    playersReady.append(email)
                }
                let data: [String: Any] = [
                    "playersReady": playersReady
                ]
                FirestoreManager.shared.updateData(data: data)
            case .failure(let error):
                print("Error getting document:\(error)")
            }
        }
    }
    func loadReadyPlayers() {
        let existingPlayers: Set<String> = Set(self.readyPlayers)
        documentListener = FirestoreManager.shared.addSnapShotListener { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let document):
                guard let document = document else {
                    return
                }
                if let players = document["player"] as? [String] {
                    playerNumber = players.count
                }
                if let playersReady = document["playersReady"] as? [String] {
                    let newPlayers = playersReady.filter { !existingPlayers.contains($0) }
                    readyPlayers = newPlayers
                }
                if isAllPlayersReady() {
                    FirestoreManager.shared.updateData(data: ["playersReady": [String]()])
                    let speakVC = SpeakViewController()
                    vibrateHard()
                    navigationController?.pushViewController(speakVC, animated: true)
                }
            case .failure(let error):
                print("Error getting document:\(error)")
            }
        }
    }
    func isAllPlayersReady() -> Bool {
        return self.readyPlayers.count == playerNumber
    }
}
