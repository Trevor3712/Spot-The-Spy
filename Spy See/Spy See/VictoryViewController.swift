//
//  VictoryViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/18.
//

import UIKit
import FirebaseFirestore

class VictoryViewController: BaseViewController {
    lazy var identityImageView = UIImageView()
    lazy var victoryLabel = UILabel()
    lazy var backToLobbyButton: BaseButton = {
        let backToLobbyButton = BaseButton()
        backToLobbyButton.setNormal("回到大廳")
        backToLobbyButton.setHighlighted("回到大廳")
        backToLobbyButton.titleLabel?.textAlignment = .center
        backToLobbyButton.addTarget(self, action: #selector(backToLobbyButtonPressed), for: .touchUpInside)
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
            victoryLabel.attributedText = UIFont.fontStyle(
                font: .boldItalicEN,
                title: "臥底獲勝",
                size: 45,
                textColor: .Y ?? .black,
                letterSpacing: 10)
            identityImageView.image = .asset(.spy)
        } else {
            victoryLabel.attributedText = UIFont.fontStyle(
                font: .boldItalicEN,
                title: "平民獲勝",
                size: 45,
                textColor: .Y ?? .black,
                letterSpacing: 10)
            identityImageView.image = .asset(.normalWin)
        }
    }
    func configureLayout() {
        [identityImageView, victoryLabel, backToLobbyButton].forEach { view.addSubview($0) }
        victoryLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
        }
        identityImageView.snp.makeConstraints { make in
            make.bottom.equalTo(victoryLabel.snp.top).offset(-100)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(150)
        }
        backToLobbyButton.snp.makeConstraints { make in
            make.top.equalTo(victoryLabel.snp.bottom).offset(150)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
    }
    @objc func backToLobbyButtonPressed() {
        vibrate()
        if let targetViewController = navigationController?.viewControllers[1] {
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
