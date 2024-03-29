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
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentSize.width = 0
        scrollView.contentSize.height = 750
        return scrollView
    }()
    private lazy var contentView = UIView()
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "你覺得誰是臥底？",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        return titleLabel
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseIdentifier)
        return tableView
    }()
    private lazy var voteButton: BaseButton = {
        let voteButton = BaseButton()
        voteButton.setNormal("投票")
        voteButton.setHighlighted("投票")
        voteButton.addTarget(self, action: #selector(voteButtonPressed), for: .touchUpInside)
        return voteButton
    }()
    private var players = UserDefaults.standard.stringArray(forKey: UDConstants.playersArray)
    private var votedPlayer: String?
    private var selectedIndexPath: IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentUser = UserDefaults.standard.string(forKey: UDConstants.userName)
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
    }
    @objc private func voteButtonPressed() {
        playSeAudio()
        vibrate()
        guard votedPlayer != nil else {
            let alertVC = AlertViewController()
            let alert = alertVC.showAlert(title: "投票錯誤", message: "請選擇你想殺死的玩家")
            present(alert, animated: true)
            return
        }
        let email = Auth.auth().currentUser?.email
        let data = [FirestoreConstans.voted: FieldValue.arrayUnion([["\(email ?? "")": votedPlayer ?? ""]])]
        FirestoreManager.shared.updateData(data: data) { [weak self] in
            guard let self = self else { return }
            let killVC = KillViewController()
            navigationController?.pushViewController(killVC, animated: true)
        }
    }
}

extension VoteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        players?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PlayerCell.reuseIdentifier) as? PlayerCell else { fatalError("Can't create cell") }
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
            vibrate()
            if let url = Bundle.main.url(forResource: SoundConstant.gunLoaded, withExtension: SoundConstant.wav) {
                playSeAudio(from: url)
            }
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
