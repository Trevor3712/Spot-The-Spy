//
//  DiedViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/19.
//

import UIKit
import FirebaseFirestore

class DiedViewController: BaseViewController {
    private lazy var diedImageView = UIImageView()
    private lazy var diedLabel: UILabel = {
        let diedLabel = UILabel()
        diedLabel.backgroundColor = .white
        diedLabel.layer.borderWidth = 1
        diedLabel.layer.borderColor = UIColor.B1?.cgColor
        diedLabel.layer.cornerRadius = 20
        diedLabel.clipsToBounds = true
        diedLabel.textAlignment = .center
        diedLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "你已經死了",
            size: 45,
            textColor: .R ?? .black,
            letterSpacing: 10)
        return diedLabel
    }()
    private lazy var remindLabel: UILabel = {
        let remindLabel = UILabel()
        remindLabel.attributedText = UIFont.fontStyle(
            font: .regular,
            title: "＊若遊戲結束將自動返回勝利頁面",
            size: 15,
            textColor: .B3 ?? .black,
            letterSpacing: 0)
        return remindLabel
    }()
    private var documentListener: ListenerRegistration?
    override func viewDidLoad() {
        super.viewDidLoad()
        [diedImageView, diedLabel, remindLabel].forEach { view.addSubview($0) }
        diedLabel.snp.makeConstraints { make in
            make.centerY.equalTo(view).offset(30)
            make.centerX.equalTo(view)
            make.width.equalTo(300)
            make.height.equalTo(80)
        }
        diedImageView.snp.makeConstraints { make in
            make.bottom.equalTo(diedLabel.snp.top).offset(-80)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
        remindLabel.snp.makeConstraints { make in
            make.top.equalTo(diedLabel.snp.bottom).offset(80)
            make.centerX.equalTo(view)
        }
        checkIfEndGame()
        showImage()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        documentListener?.remove()
    }
    private func showImage() {
        let playerIdentity = UserDefaults.standard.string(forKey: "playerIdentity")
        if playerIdentity == "平民" {
            diedImageView.image = .asset(.normalKilled)
        } else {
            diedImageView.image = .asset(.spyKilled)
        }
    }
    private func checkIfEndGame() {
        documentListener = FirestoreManager.shared.addSnapShotListener { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let document):
                guard let document = document else {
                    return
                }
                if let isSpyWin = document["isSpyWin"] as? Bool {
                    if isSpyWin == false {
                        goToVictoryPage(false)
                    } else {
                        goToVictoryPage(true)
                    }
                }
            case .failure(let error):
                print("Error getting document:\(error)")
            }
        }
    }
    private func goToVictoryPage(_ isSpyWin: Bool) {
        let victoryVC = VictoryViewController()
        victoryVC.isSpyWin = isSpyWin
        vibrateHard()
        navigationController?.pushViewController(victoryVC, animated: true)
    }
}
