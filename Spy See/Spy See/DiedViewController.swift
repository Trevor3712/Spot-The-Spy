//
//  DiedViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/19.
//

import UIKit
import FirebaseFirestore

class DiedViewController: UIViewController {
    lazy var diedLabel = UILabel()
    let dataBase = Firestore.firestore()
//    var ifEndGame = false
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(diedLabel)
        diedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            diedLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 300),
            diedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        diedLabel.text = "你已經死了！"
        checkIfEndGame()
    }
    func checkIfEndGame() {
        let room = dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        documentRef.addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                print(error)
                return
            }
            guard let data = documentSnapshot?.data() else {
                print("No data available")
                return
            }
            if let isSpyWin = data["isSpyWin"] as? Bool {
                if isSpyWin == false {
                    self.goToVictoryPage(false)
                } else {
                    self.goToVictoryPage(true)
                }
            }
        }
    }
    func goToVictoryPage(_ isSpyWin: Bool) {
        let victoryVC = VictoryViewController()
        victoryVC.isSpyWin = isSpyWin
        navigationController?.pushViewController(victoryVC, animated: true)
    }
}
