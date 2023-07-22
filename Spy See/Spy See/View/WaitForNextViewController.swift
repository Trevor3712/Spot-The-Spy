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
    private lazy var remindLabel: UILabel = {
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
    private var documentListener: ListenerRegistration?
    private let currentPlayers = UserDefaults.standard.stringArray(forKey: "playersArray")
    private var readyPlayers: [String] = []
    private let currentUser = Auth.auth().currentUser?.email ?? ""
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
    private func readyToGO() {
        // swiftlint:disable array_constructor
        let data = ["playersReady": FieldValue.arrayUnion([currentUser])]
        // swiftlint:enable array_constructor
        FirestoreManager.shared.updateData(data: data)
    }
    private func loadReadyPlayer() {
        let existingPlayers: Set<String> = Set(self.readyPlayers)
        documentListener = FirestoreManager.shared.addSnapShotListener { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let document):
                guard let document = document else {
                    return
                }
                let playersReady = document["playersReady"] as? [String] ?? []
                let newPlayers = playersReady.filter { !existingPlayers.contains($0) }
                readyPlayers = newPlayers
                if isAllPlayersReady() {
                    documentListener?.remove()
                    FirestoreManager.shared.updateData(data: ["playersReady": [String]()]) { [weak self] in
                        guard let self = self else { return }
                        if let targetViewController =
                            navigationController?.viewControllers.first(where: { $0 is SpeakViewController }) {
                            vibrateHard()
                            navigationController?.popToViewController(targetViewController, animated: true)
                        }
                    }
                }
            case .failure(let error):
                print("Error getting document:\(error)")
            }
        }
    }
    private func isAllPlayersReady() -> Bool {
        return self.readyPlayers.count == self.currentPlayers?.count
    }
}
