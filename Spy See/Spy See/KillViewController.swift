//
//  KillViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/17.
//

import UIKit
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
        // 查找出現次數最多的值
        if let (mostFrequentValue, _) = voteCount.max(by: { $0.value < $1.value }) {
            let players = UserDefaults.standard.stringArray(forKey: "playersArray")
            playersArray = players ?? [""]
            if let index = players?.firstIndex(of: mostFrequentValue) {
                arrayIndex = index
                print("mostFrequentValue: \(mostFrequentValue), index: \(index)")
                self.waitLabel.text = ""
                self.votedLabel.text = "\(mostFrequentValue)被殺死了！"
                self.identityLabel.text = "他的身份是\(identitiesArray[index])"
            }
        }
    }
    @IBAction func nextRound(_ sender: UIButton) {
        self.playersArray.remove(at: arrayIndex ?? 0)
        self.identitiesArray.remove(at: arrayIndex ?? 0)
        self.votedArray.removeAll()
        self.updateData()
        let countCivilian = identitiesArray.filter { $0 == "平民" }.count
        let countSpy = identitiesArray.filter { $0 == "臥底" }.count
        if countSpy == 0 {
            // 去平民獲勝頁面
            print("平民獲勝！")
//            performSegue(withIdentifier: "KillToVictory", sender: self)
            goToVictoryVC(false)
        } else if countSpy >= countCivilian {
            // 去臥底獲勝頁面
            print("臥底獲勝！")
            goToVictoryVC(true)
        } else {
            // 回到發言頁
            print("繼續下一輪")
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
}
//extension KillViewController {
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "KillToVictory" {
//            
//        }
//    }
//}
