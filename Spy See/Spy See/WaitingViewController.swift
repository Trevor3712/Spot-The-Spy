//
//  WaitingViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/16.
//

import UIKit
import FirebaseFirestore

class WaitingViewController: UIViewController {
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseIdentifier)
        return tableView
    }()
    let dataBase = Firestore.firestore()
    var players: [String] = []
    var playerNumber: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        players = []
        loadRoomData()
    }
    func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200)
        ])
    }
    func loadRoomData() {
        guard let roomId = UserDefaults.standard.string(forKey: "roomId"), !roomId.isEmpty else {
            print("Invalid roomId")
            return
        }
        let documentRef = dataBase.collection("Rooms").document(roomId)
        var existingPlayers: Set<String> = Set(self.players)
        documentRef.addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                print(error)
                return
            }
            guard let data = documentSnapshot?.data() else {
                print("No data available")
                return
            }
            if let playerNumberData = data["playerNumber"] as? String {
                self.playerNumber = Int(playerNumberData)
            }
            if let playersData = data["player"] as? [String] {
                self.players = []
                let newPlayers = playersData.filter { !existingPlayers.contains($0) }
                self.players.append(contentsOf: newPlayers)
                self.tableView.reloadData()
                
                if self.allPlayersJoined() {
                    self.performSegue(withIdentifier: "waitingToPrompt", sender: self)
                }
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
        cell.titleLabel.text = players[indexPath.row]
        return cell
    }
}
extension WaitingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }
}

extension WaitingViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "waitingToPrompt" {
//            if let promptVC = segue.destination as? PassPromptViewController {
//
//            }
        }
    }
}
