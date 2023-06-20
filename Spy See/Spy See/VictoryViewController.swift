//
//  VictoryViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/18.
//

import UIKit
import FirebaseFirestore

class VictoryViewController: UIViewController {
    lazy var victoryLabel = UILabel()
    lazy var backToLobbyButton: UIButton = {
        let backToLobbyButton = UIButton()
        backToLobbyButton.setTitle("回遊戲大廳", for: .normal)
        backToLobbyButton.setTitleColor(.black, for: .normal)
        return backToLobbyButton
    }()
    let dataBase = Firestore.firestore()
    var isSpyWin = true
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        whoWins()
        configureLayout()
    }
    func whoWins() {
        if isSpyWin {
            victoryLabel.text = "臥底獲勝！"
        } else {
            victoryLabel.text = "平民獲勝！"
        }
    }
    func configureLayout() {
        [victoryLabel, backToLobbyButton].forEach { view.addSubview($0) }
        [victoryLabel, backToLobbyButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            victoryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            victoryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backToLobbyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            backToLobbyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backToLobbyButton.widthAnchor.constraint(equalToConstant: 100),
            backToLobbyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        backToLobbyButton.addTarget(self, action: #selector(backToLobby), for: .touchUpInside)
    }
    @objc func backToLobby() {
        if let targetViewController = navigationController?.viewControllers.filter({ $0 is LobbyViewController }).first {
            navigationController?.popToViewController(targetViewController, animated: true)
            deleteGameData()
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
}
