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
    lazy var waitLabel: UILabel = {
        let waitLabel = UILabel()
        waitLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "請等待其他玩家完成投票",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        return waitLabel
    }()
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.B1?.cgColor
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true
        containerView.isHidden = true
        return containerView
    }()
    lazy var votedLabel: UILabel = {
        let votedLabel = UILabel()
        return votedLabel
    }()
    lazy var killLabel: UILabel = {
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
    lazy var identityImageView: UIImageView = {
        let identityImageView = UIImageView()
        identityImageView.image = .asset(.normalKilled)
        identityImageView.isHidden = true
        return identityImageView
    }()
    lazy var identityLabel: UILabel = {
        let identityLabel = UILabel()
        return identityLabel
    }()
    lazy var nextRoundButton: BaseButton = {
        let nextRoundButton = BaseButton()
        nextRoundButton.setNormal("下一輪")
        nextRoundButton.setHighlighted("下一輪")
        nextRoundButton.isHidden = true
        nextRoundButton.addTarget(self, action: #selector(nextRoundButtonPressed), for: .touchUpInside)
        return nextRoundButton
    }()
    let dataBase = Firestore.firestore()
    var votedArray: [[String: String]] = []
    var identitiesArray: [String] = []
    var arrayIndex: Int?
    var playersArray: [String] = []
    let players = UserDefaults.standard.stringArray(forKey: "playersArray")
    var votedListener: ListenerRegistration?
    let currentUser = Auth.auth().currentUser?.email ?? ""
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
    }
//    override func viewWillDisappear(_ animated: Bool) {
//       super.viewWillDisappear(animated)
//       votedListener?.remove()
//   }
    func loadVotedPlayers() {
        let room = dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        votedListener = documentRef.addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                print(error)
                return
            }
            guard let data = documentSnapshot?.data() else {
                print("No data available")
                return
            }
            if let voted = data["voted"] as? [[String: String]] {
                self.votedArray = voted
                print(self.votedArray)
            }
            if let identities = data["identities"] as? [String] {
                self.identitiesArray = identities
                print(self.identitiesArray)
            }
            if self.isAllPlayersVote() {
                self.killWhichPlayer()
                self.votedListener?.remove()
            }
        }
    }
    func isAllPlayersVote() -> Bool {
        return self.votedArray.count == self.playersArray.count
    }
    func killWhichPlayer() {
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
            print("Selected player: \(selectedPlayer), index: \(selectedIndex)")
            self.waitLabel.text = ""
            containerView.isHidden = false
            identityImageView.isHidden = false
            nextRoundButton.isHidden = false
            killLabel.isHidden = false
            self.votedLabel.attributedText = UIFont.fontStyle(
                font: .boldItalicEN,
                title: selectedPlayer,
                size: 45,
                textColor: .R ?? .black,
                letterSpacing: 10)
            self.identityLabel.attributedText = UIFont.fontStyle(
                font: .semibold,
                title: "他的身份是\(identitiesArray[selectedIndex])",
                size: 35,
                textColor: .R ?? .black,
                letterSpacing: 10)
            if identitiesArray[selectedIndex] == "平民" {
                identityImageView.image = .asset(.normalKilled)
            } else {
                identityImageView.image = .asset(.spyKilled)
            }
            let url = Bundle.main.url(forResource: "gunShot_se", withExtension: "wav")
            playSeAudio(from: url!)
        } else {
            // 查找出現次數最多的值
            if let (mostFrequentValue, _) = voteCount.max(by: { $0.value < $1.value }) {
                if let index = players?.firstIndex(of: mostFrequentValue) {
                    arrayIndex = index
                    print("mostFrequentValue: \(mostFrequentValue), index: \(index)")
                    containerView.isHidden = false
                    identityImageView.isHidden = false
                    nextRoundButton.isHidden = false
                    killLabel.isHidden = false
                    self.waitLabel.text = ""
                    self.votedLabel.attributedText = UIFont.fontStyle(
                        font: .boldItalicEN,
                        title: mostFrequentValue,
                        size: 45,
                        textColor: .R ?? .black,
                        letterSpacing: 10)
                    self.identityLabel.attributedText = UIFont.fontStyle(
                        font: .semibold,
                        title: "他的身份是\(identitiesArray[index])",
                        size: 35,
                        textColor: .R ?? .black,
                        letterSpacing: 10)
                    if identitiesArray[index] == "平民" {
                        identityImageView.image = .asset(.normalKilled)
                    } else {
                        identityImageView.image = .asset(.spyKilled)
                    }
                    let url = Bundle.main.url(forResource: "gunShot_se", withExtension: "wav")
                    playSeAudio(from: url!)
                }
            }
        }
    }
    @objc func nextRoundButtonPressed() {
        vibrate()
        self.playersArray.remove(at: arrayIndex ?? 0)
        self.identitiesArray.remove(at: arrayIndex ?? 0)
        self.votedArray.removeAll()
        UserDefaults.standard.removeObject(forKey: "playersArray")
        UserDefaults.standard.setValue(playersArray, forKey: "playersArray")
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
            let currentUser = UserDefaults.standard.string(forKey: "userName") ?? ""
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
    func updateData() {
        let room = dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        let data: [String: Any] = [
            "player": playersArray,
            "identities": identitiesArray,
            "voted": votedArray
        ]
        documentRef.updateData(data) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document updated successfully")
            }
        }
    }
    func goToVictoryVC(_ bool: Bool) {
        let victoryVC = VictoryViewController()
        victoryVC.isSpyWin = bool
        navigationController?.pushViewController(victoryVC, animated: true)
    }
    func updateWinMessage(_ isSpyWin: Bool) {
        let room = dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        if isSpyWin {
            let data: [String: Any] = [
                "isSpyWin": true
            ]
            documentRef.updateData(data) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document added successfully")
                }
            }
        } else {
            let data: [String: Any] = [
                "isSpyWin": false
            ]
            documentRef.updateData(data) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document added successfully")
                }
            }
        }
    }
//    func playAudio(from url: URL, loop: Bool = false) {
//        do {
//            gunShotAudioPlayer.audioPlayer = try AVAudioPlayer(contentsOf: url)
//            gunShotAudioPlayer.audioPlayer?.numberOfLoops = loop ? -1 : 0
//            gunShotAudioPlayer.audioPlayer?.prepareToPlay()
//            gunShotAudioPlayer.audioPlayer?.play()
//        } catch {
//            print("Failed to play audio: \(error.localizedDescription)")
//        }
//    }
}
