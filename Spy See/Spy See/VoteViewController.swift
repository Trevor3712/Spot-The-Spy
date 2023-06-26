//
//  VoteViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/17.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class VoteViewController: BaseViewController {
    @IBOutlet weak var voteButton: UIButton!
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseIdentifier)
        return tableView
    }()
    var players = UserDefaults.standard.stringArray(forKey: "playersArray")
    let dataBase = Firestore.firestore()
    var votedPlayer: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
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
}

extension VoteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        players?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.reuseIdentifier) as? PlayerCell else { fatalError("Can't create cell") }
        cell.titleLabel.text = players?[indexPath.row]
        return cell
    }
}
extension VoteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PlayerCell else {
            fatalError("Can't create cell")
        }
        votedPlayer = cell.titleLabel.text
    }
    @IBAction func addVotedPlayer(_ sender: UIButton) {
        let room = dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        let email = Auth.auth().currentUser?.email

        documentRef.updateData(["voted": FieldValue.arrayUnion([["\(email ?? "")": votedPlayer ?? ""]])]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document updated successfully")
//                self.voteButton.isEnabled = false
            }
        }
    }
}
