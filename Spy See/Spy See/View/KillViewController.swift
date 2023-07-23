//
//  KillViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/17.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import AVFoundation

class KillViewController: BaseViewController {
    private lazy var waitLabel: UILabel = {
        let waitLabel = UILabel()
        waitLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "請等待其他玩家完成投票",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        return waitLabel
    }()
    private lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.B1?.cgColor
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true
        containerView.isHidden = true
        return containerView
    }()
    private lazy var votedLabel: UILabel = {
        let votedLabel = UILabel()
        return votedLabel
    }()
    private lazy var killLabel: UILabel = {
        let killLabel = UILabel()
        killLabel.attributedText = UIFont.fontStyle(
            font: .boldItalicEN,
            title: "被殺死了！",
            size: 35,
            textColor: .R ?? .black,
            letterSpacing: 10)
        killLabel.isHidden = true
        return killLabel
    }()
    private lazy var identityImageView: UIImageView = {
        let identityImageView = UIImageView()
        identityImageView.image = .asset(.normalKilled)
        identityImageView.isHidden = true
        return identityImageView
    }()
    private lazy var identityLabel: UILabel = {
        let identityLabel = UILabel()
        return identityLabel
    }()
    private lazy var nextRoundButton: BaseButton = {
        let nextRoundButton = BaseButton()
        nextRoundButton.setNormal("下一輪")
        nextRoundButton.setHighlighted("下一輪")
        nextRoundButton.isHidden = true
        nextRoundButton.addTarget(self, action: #selector(nextRoundButtonPressed), for: .touchUpInside)
        return nextRoundButton
    }()
    var votedArray: [[String: String]] = []
    private var identitiesArray: [String] = []
    private var arrayIndex: Int?
    var playersArray: [String] = []
    private let players = UserDefaults.standard.stringArray(forKey: UDConstants.playersArray)
    private var documentListener: ListenerRegistration?
    private let currentUser = Auth.auth().currentUser?.email ?? ""
    override func viewDidLoad() {
        super.viewDidLoad()
        [waitLabel, containerView, identityImageView, nextRoundButton].forEach { view.addSubview($0) }
        [votedLabel, killLabel, identityLabel].forEach { containerView.addSubview($0) }
        waitLabel.snp.makeConstraints { make in
            make.top.equalTo(view).offset(100)
            make.centerX.equalTo(view)
        }
        identityImageView.snp.makeConstraints { make in
            make.top.equalTo(view).offset(150)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
        containerView.snp.makeConstraints { make in
            make.top.equalTo(identityImageView.snp.bottom).offset(30)
            make.centerX.equalTo(view)
            make.width.equalTo(350)
            make.height.equalTo(220)
        }
        votedLabel.snp.makeConstraints { make in
            make.bottom.equalTo(killLabel.snp.top).offset(-12)
            make.centerX.equalTo(containerView)
        }
        killLabel.snp.makeConstraints { make in
            make.centerY.equalTo(containerView)
            make.centerX.equalTo(containerView)
        }
        identityLabel.snp.makeConstraints { make in
            make.top.equalTo(killLabel.snp.bottom).offset(12)
            make.centerX.equalTo(containerView)
        }
        nextRoundButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(50)
            make.centerX.equalTo(view)
            make.width.equalTo(115)
            make.height.equalTo(40)
        }
        playersArray = players ?? [""]
        loadVotedPlayers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AudioPlayer.shared.stopAudio()
        documentListener?.remove()
    }
    private func loadVotedPlayers() {
        documentListener = FirestoreManager.shared.addSnapShotListener { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let document):
                guard let document = document else {
                    return
                }
                if let voted = document[FirestoreConstans.voted] as? [[String: String]] {
                    votedArray = voted
                    print(self.votedArray)
                }
                if let identities = document[FirestoreConstans.identities] as? [String] {
                    identitiesArray = identities
                    print(self.identitiesArray)
                }
                if isAllPlayersVote() {
                    showKilledPlayer(
                        nameTitle: killWhichPlayer().selectedPlayer,
                        identityIndex: killWhichPlayer().selectedIndex)
                    documentListener?.remove()
                }
            case .failure(let error):
                print("Error getting document:\(error)")
            }
        }
    }
    private func isAllPlayersVote() -> Bool {
        return self.votedArray.count == self.playersArray.count
    }
    func killWhichPlayer() -> (selectedPlayer: String, selectedIndex: Int) {
        var voteCount: [String: Int] = [:]
        // 計算每個值的出現次數
        for dict in votedArray {
            for (_, value) in dict {
                voteCount[value, default: 0] += 1
            }
        }
        // 檢查是否有平手的狀況
        let maxVoteCount = voteCount.values.max() ?? 0
        let tiedPlayers = voteCount.filter { $0.value == maxVoteCount }
        if tiedPlayers.count > 1 {
            // 排序平手玩家的索引
            let sortedIndexes = tiedPlayers.keys.compactMap { playersArray.firstIndex(of: $0) }.sorted()
            let selectedIndex = sortedIndexes.first ?? 0
            let selectedPlayer = playersArray[selectedIndex]
            return (selectedPlayer: selectedPlayer, selectedIndex: selectedIndex)
        } else {
            // 查找出現次數最多的值
            var selectedPlayer = ""
            var selectedIndex = 0
            if let maxVote = voteCount.max(by: { $0.value < $1.value }) {
                selectedPlayer = maxVote.key
                selectedIndex = playersArray.firstIndex(of: selectedPlayer) ?? 0
                arrayIndex = selectedIndex
            }
            return (selectedPlayer: selectedPlayer, selectedIndex: selectedIndex)
        }
    }
    private func showKilledPlayer(nameTitle: String, identityIndex: Int) {
        containerView.isHidden = false
        identityImageView.isHidden = false
        nextRoundButton.isHidden = false
        killLabel.isHidden = false
        self.waitLabel.text = ""
        self.votedLabel.attributedText = UIFont.fontStyle(
            font: .boldItalicEN,
            title: nameTitle,
            size: 45,
            textColor: .R ?? .black,
            letterSpacing: 10)
        self.identityLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "他的身份是\(identitiesArray[identityIndex])",
            size: 35,
            textColor: .R ?? .black,
            letterSpacing: 10)
        if identitiesArray[identityIndex] == "平民" {
            identityImageView.image = .asset(.normalKilled)
        } else {
            identityImageView.image = .asset(.spyKilled)
        }
        if let url = Bundle.main.url(forResource: SoundConstant.gunShot, withExtension: SoundConstant.wav) {
            playSeAudio(from: url)
        }
    }
    @objc private func nextRoundButtonPressed() {
        playSeAudio()
        vibrate()
        self.playersArray.remove(at: arrayIndex ?? 0)
        self.identitiesArray.remove(at: arrayIndex ?? 0)
        self.votedArray.removeAll()
        UserDefaults.standard.setValue(playersArray, forKey: UDConstants.playersArray)
        print(playersArray)
        self.updateData()
        let countCivilian = identitiesArray.filter { $0 == "平民" }.count
        let countSpy = identitiesArray.filter { $0 == "臥底" }.count
        if countSpy == 0 {
            print("平民獲勝！")
            goToVictoryVC(false)
            updateWinMessage(false)
        } else if countSpy >= countCivilian {
            print("臥底獲勝！")
            goToVictoryVC(true)
            updateWinMessage(true)
        } else {
            print("繼續下一輪")
            let currentUser = UserDefaults.standard.string(forKey: UDConstants.userName) ?? ""
            print("currentUser:\(currentUser)")
            print("playersArray: \(playersArray)")
            if playersArray.contains(currentUser) {
                let waitForNextVC = WaitForNextViewController()
                navigationController?.pushViewController(waitForNextVC, animated: true)
            } else {
                let diedVC = DiedViewController()
                navigationController?.pushViewController(diedVC, animated: true)
            }
        }
    }
    private func updateData() {
        let data: [String: Any] = [
            FirestoreConstans.player: playersArray,
            FirestoreConstans.identities: identitiesArray,
            FirestoreConstans.voted: votedArray
        ]
        FirestoreManager.shared.updateData(data: data)
    }
    private func goToVictoryVC(_ bool: Bool) {
        let victoryVC = VictoryViewController()
        victoryVC.isSpyWin = bool
        navigationController?.pushViewController(victoryVC, animated: true)
    }
    private func updateWinMessage(_ isSpyWin: Bool) {
        if isSpyWin {
            let data: [String: Any] = [
                FirestoreConstans.isSpyWin: true
            ]
            FirestoreManager.shared.updateData(data: data)
        } else {
            let data: [String: Any] = [
                FirestoreConstans.isSpyWin: false
            ]
            FirestoreManager.shared.updateData(data: data)
        }
    }
}
