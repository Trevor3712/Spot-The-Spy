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
    let dataBase = Firestore.firestore()
    var votedArray: [[String: String]] = []
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
                    self.killWhchPlayer()
                }
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
            if let index = players?.firstIndex(of: mostFrequentValue) {
                print("mostFrequentValue: \(mostFrequentValue), index: \(index)")
                self.waitLabel.text = ""
                self.votedLabel.text = "\(mostFrequentValue)被殺死了！"
            }
        }
    }
}
