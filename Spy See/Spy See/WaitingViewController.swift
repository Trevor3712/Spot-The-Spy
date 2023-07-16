//
//  WaitingViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/16.
//

import UIKit
import FirebaseFirestore

class WaitingViewController: BaseViewController {
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "遊戲將在玩家到齊後開始...",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        return titleLabel
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseIdentifier)
        return tableView
    }()
    var documentListener: ListenerRegistration?
    var players: [String] = []
    var playerNumber: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        [titleLabel, tableView].forEach { view.addSubview($0) }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view).offset(105)
            make.centerX.equalTo(view)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.left.equalTo(view).offset(36)
            make.right.equalTo(view).offset(-36)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }
        players = []
        loadRoomData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        documentListener?.remove()
        UserDefaults.standard.setValue(players, forKey: "playersArray")
    }
    func loadRoomData() {
        let existingPlayers: Set<String> = Set(self.players)
        documentListener = FirestoreManager.shared.addSnapShotListener { result in
            switch result {
            case .success(let document):
                guard let document = document else {
                    return
                }
                if let playerNumberData = document["playerNumber"] as? String {
                    self.playerNumber = Int(playerNumberData)
                }
                if let playersData = document["player"] as? [String] {
                    self.players = []
                    let newPlayers = playersData.filter { !existingPlayers.contains($0) }
                    self.players.append(contentsOf: newPlayers)
                    self.tableView.reloadData()
                    if self.allPlayersJoined() {
                        let promptVC = PassPromptViewController()
                        self.vibrateHard()
                        self.navigationController?.pushViewController(promptVC, animated: true)
                    }
                }
            case .failure(let error):
                print("Error getting document:\(error)")
            }
        }
    }
    func allPlayersJoined() -> Bool {
        return self.players.count == playerNumber
    }
}

extension WaitingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        players.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.reuseIdentifier) as? PlayerCell else { fatalError("Can't create cell") }
        cell.titleLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: players[indexPath.row],
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        cell.backgroundColor = .clear
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.knifeImageView.isHidden = true
        return cell
    }
}
extension WaitingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PlayerCell else {
            fatalError("Can't create cell")
        }
        cell.selectionStyle = .none
    }
}
