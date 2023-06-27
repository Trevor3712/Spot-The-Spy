//
//  DiedViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/19.
//

import UIKit
import FirebaseFirestore

class DiedViewController: BaseViewController {
    lazy var diedImageView = UIImageView()
    lazy var diedLabel: UILabel = {
        let diedLabel = UILabel()
        diedLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "你已經死了",
            size: 45,
            textColor: .R ?? .black,
            letterSpacing: 10)
        return diedLabel
    }()
    lazy var remindLabel: UILabel = {
        let remindLabel = UILabel()
        remindLabel.attributedText = UIFont.fontStyle(
            font: .regular,
            title: "＊若遊戲結束將自動返回勝利頁面",
            size: 15,
            textColor: .B3 ?? .black,
            letterSpacing: 0)
        return remindLabel
    }()
    let dataBase = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        [diedImageView, diedLabel, remindLabel].forEach { view.addSubview($0) }
        diedLabel.snp.makeConstraints { make in
            make.centerY.equalTo(view)
            make.centerX.equalTo(view)
        }
        diedImageView.snp.makeConstraints { make in
            make.bottom.equalTo(diedLabel.snp.top).offset(-100)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(150)
        }
        remindLabel.snp.makeConstraints { make in
            make.top.equalTo(diedLabel.snp.bottom).offset(50)
            make.centerX.equalTo(view)
        }
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
