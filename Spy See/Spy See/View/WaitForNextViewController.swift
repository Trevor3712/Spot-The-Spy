//
//  WaitForNextViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class WaitForNextViewController: BaseViewController {
    lazy var remindLabel: UILabel = {
        let remindLabel = UILabel()
        remindLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "請等待其他玩家到齊",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        remindLabel.layer.borderWidth = 1
        remindLabel.layer.borderColor = UIColor.B1?.cgColor
        remindLabel.backgroundColor = .white
        remindLabel.layer.cornerRadius = 10
        remindLabel.clipsToBounds = true
        remindLabel.textAlignment = .center
        return remindLabel
    }()
    var documentListener: ListenerRegistration?
    let currentPlayers = UserDefaults.standard.stringArray(forKey: "playersArray")
    var readyPlayers: [String] = []
    let currentUser = Auth.auth().currentUser?.email ?? ""
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(remindLabel)
        remindLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.width.equalTo(250)
            make.height.equalTo(40)
        }
        readyToGO()
        loadReadyPlayer()
    }
    func readyToGO() {
        let data = ["playersReady": FieldValue.arrayUnion([currentUser])]
        FirestoreManager.shared.updateData(data: data)
    }
    func loadReadyPlayer() {
        let existingPlayers: Set<String> = Set(self.readyPlayers)
        documentListener = FirestoreManager.shared.addSnapShotListener { result in
            switch result {
            case .success(let document):
                guard let document = document else {
                    return
                }
                let playersReady = document["playersReady"] as? [String] ?? []
                let newPlayers = playersReady.filter { !existingPlayers.contains($0) }
                self.readyPlayers = newPlayers
                if self.isAllPlayersReady() {
                    self.documentListener?.remove()
                    FirestoreManager.shared.updateData(data: ["playersReady": [String]()]) {
                        if let targetViewController =
                            self.navigationController?.viewControllers.first(where: { $0 is SpeakViewController }) {
                            self.vibrateHard()
                            self.navigationController?.popToViewController(targetViewController, animated: true)
                        }
                    }
                }
            case .failure(let error):
                print("Error getting document:\(error)")
            }
        }
    }
    func isAllPlayersReady() -> Bool {
        return self.readyPlayers.count == self.currentPlayers?.count
    }
}
