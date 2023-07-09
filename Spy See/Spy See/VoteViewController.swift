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
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentSize.width = 0
        scrollView.contentSize.height = 750
        return scrollView
    }()
    lazy var contentView = UIView()
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "你覺得誰是臥底？",
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
    lazy var voteButton: BaseButton = {
        let voteButton = BaseButton()
        voteButton.setNormal("投票")
        voteButton.setHighlighted("投票")
        voteButton.addTarget(self, action: #selector(voteButtonPressed), for: .touchUpInside)
        return voteButton
    }()
    var players = UserDefaults.standard.stringArray(forKey: "playersArray")
    let dataBase = Firestore.firestore()
    var votedPlayer: String?
    var selectedIndexPath: IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentUser = UserDefaults.standard.string(forKey: "userName")
        players?.removeAll { $0 == currentUser }
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [titleLabel, tableView, voteButton].forEach { contentView.addSubview($0) }
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 750)
        ])
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.centerX.equalTo(contentView)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.left.equalTo(contentView).offset(36)
            make.right.equalTo(contentView).offset(-36)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-100)
        }
        voteButton.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(30)
            make.centerX.equalTo(contentView)
            make.width.equalTo(115)
            make.height.equalTo(40)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let url = Bundle.main.url(forResource: "vote_bgm", withExtension: "wav")
        AudioPlayer.shared.playAudio(from: url!, loop: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AudioPlayer.shared.stopAudio()
    }
    @objc func voteButtonPressed() {
        vibrate()
        guard let voted = votedPlayer else {
            let alertVC = AlertViewController()
            let alert = alertVC.showAlert(title: "投票錯誤", message: "請選擇你想殺死的玩家")
            present(alert, animated: true)
            return
        }
        let room = dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        let email = Auth.auth().currentUser?.email

        documentRef.updateData(["voted": FieldValue.arrayUnion([["\(email ?? "")": votedPlayer ?? ""]])]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document updated successfully")
                let killVC = KillViewController()
                self.navigationController?.pushViewController(killVC, animated: true)
            }
        }
    }
}

extension VoteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        players?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.reuseIdentifier) as? PlayerCell else { fatalError("Can't create cell") }
        cell.titleLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: players?[indexPath.row] ?? "",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        cell.backgroundColor = .clear
        cell.layer.backgroundColor = UIColor.clear.cgColor
        if let selectedIndexPath = selectedIndexPath, selectedIndexPath == indexPath {
            cell.knifeImageView.isHidden = false
        } else {
            cell.knifeImageView.isHidden = true
        }
        return cell
    }
}
extension VoteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PlayerCell else {
            fatalError("Can't create cell")
        }
        votedPlayer = cell.titleLabel.text
        cell.selectionStyle = .none
        if let selectedIndexPath = selectedIndexPath, selectedIndexPath == indexPath {
            self.selectedIndexPath = nil
        } else {
            self.selectedIndexPath = indexPath
        }
        tableView.reloadData()
    }
}
