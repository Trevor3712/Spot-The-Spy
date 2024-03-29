//
//  InviteViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/15.
//

import UIKit

class InviteViewController: BaseViewController {
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "邀請碼",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        return titleLabel
    }()
    private lazy var invitationLabel: UILabel = {
        let invitationLabel = UILabel()
        invitationLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: roomId ?? "",
            size: 50,
            textColor: .B2 ?? .black,
            letterSpacing: 20)
        invitationLabel.backgroundColor = .white
        invitationLabel.layer.borderWidth = 1
        invitationLabel.layer.borderColor = UIColor.B1?.cgColor
        invitationLabel.layer.cornerRadius = 20
        invitationLabel.clipsToBounds = true
        invitationLabel.textAlignment = .center
        return invitationLabel
    }()
    private lazy var shareButton: BaseButton = {
        let shareButton = BaseButton()
        shareButton.setNormal("分享邀請碼")
        shareButton.setHighlighted("分享邀請碼")
        shareButton.addTarget(self, action: #selector(shareButtonPressed), for: .touchUpInside)
        return shareButton
    }()
    private lazy var readyButton: BaseButton = {
        let readyButton = BaseButton()
        readyButton.setNormal("進入房間")
        readyButton.setHighlighted("進入房間")
        readyButton.addTarget(self, action: #selector(readyButtonPressed), for: .touchUpInside)
        return readyButton
    }()
    private let roomId = UserDefaults.standard.string(forKey: UDConstants.roomId)
    override func viewDidLoad() {
        super.viewDidLoad()
        [titleLabel, invitationLabel, shareButton, readyButton].forEach { view.addSubview($0) }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            make.centerX.equalTo(view)
        }
        invitationLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel).offset(100)
            make.centerX.equalTo(view)
            make.width.equalTo(250)
            make.height.height.equalTo(80)
        }
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(invitationLabel.snp.bottom).offset(50)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        readyButton.snp.makeConstraints { make in
            make.top.equalTo(shareButton.snp.bottom).offset(130)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
    }
    @objc private func shareButtonPressed() {
        playSeAudio()
        vibrate()
        presentShareSheet()
    }
    @objc private func readyButtonPressed() {
        playSeAudio()
        vibrate()
        let waitingVC = WaitingViewController()
        navigationController?.pushViewController(waitingVC, animated: true)
    }
    private func presentShareSheet() {
        if let url = URL(string: "SpotTheSpyOnline://lobby/\(roomId ?? "")") {
            let text = "趕快來跟我玩誰是臥底，邀請碼：\(roomId ?? "")"
            let shareSheetVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
            present(shareSheetVC, animated: true)
        }
    }
}
