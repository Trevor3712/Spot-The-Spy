//
//  KillViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/17.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class KillViewController: UIViewController {
    @IBOutlet weak var votedLabel: UILabel!
    @IBOutlet weak var waitLabel: UILabel!
    @IBOutlet weak var identityLabel: UILabel!
    @IBOutlet weak var nextRoundButton: UIButton!
    let dataBase = Firestore.firestore()
    var votedArray: [[String: String]] = []
    var identitiesArray: [String] = []
    var arrayIndex: Int?
    var playersArray: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        loadVotedPlayers()
    }
    func loadVotedPlayers() {
        let room = dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            documentRef.getDocument { (documentSnapshot, error) in
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
                self.killWhchPlayer()
            }
        }
    }
    func killWhchPlayer() {
        var voteCount: [String: Int] = [:]
        // 計算每個值的出現次數
        for dict in votedArray {
            for (_, value) in dict {
                voteCount[value, default: 0] += 1
            }
        }
        let players = UserDefaults.standard.stringArray(forKey: "playersArray")
        playersArray = players ?? [""]
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
            self.votedLabel.text = "\(selectedPlayer)被殺死了！"
            self.identityLabel.text = "他的身份是\(identitiesArray[selectedIndex])"
        } else {
            // 查找出現次數最多的值
            if let (mostFrequentValue, _) = voteCount.max(by: { $0.value < $1.value }) {
                if let index = players?.firstIndex(of: mostFrequentValue) {
                    arrayIndex = index
                    print("mostFrequentValue: \(mostFrequentValue), index: \(index)")
                    self.waitLabel.text = ""
                    self.votedLabel.text = "\(mostFrequentValue)被殺死了！"
                    self.identityLabel.text = "他的身份是\(identitiesArray[index])"
                }
            }
        }
    }
    @IBAction func nextRound(_ sender: UIButton) {
        self.playersArray.remove(at: arrayIndex ?? 0)
        self.identitiesArray.remove(at: arrayIndex ?? 0)
        self.votedArray.removeAll()
        UserDefaults.standard.removeObject(forKey: "playersArray")
        UserDefaults.standard.setValue(playersArray, forKey: "playersArray")
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
            let currentUser = Auth.auth().currentUser?.email ?? ""
            if playersArray.contains(currentUser) {
                performSegue(withIdentifier: "KillToSpeak", sender: self)
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
            "voted": votedArray,
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
}
extension KillViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "KillToSpeak" {
        }
    }
}
