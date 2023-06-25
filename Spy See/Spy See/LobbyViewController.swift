//
//  LobbyViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/15.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LobbyViewController: BaseViewController {
    lazy var logoImage: UIImageView = {
        let logoImage = UIImageView()
        logoImage.image = .asset(.spy)
        return logoImage
    }()
    lazy var createRoomButton: BaseButton = {
        let createRoomButton = BaseButton()
        createRoomButton.setAttributedTitle(UIFont.fontStyle(
            font: .regular,
            title: "建立遊戲",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5), for: .normal)
        createRoomButton.titleLabel?.textAlignment = .center
        createRoomButton.addTarget(self, action: #selector(createRoomButtonPressed), for: .touchUpInside)
        return createRoomButton
    }()
    lazy var joinLabel1: UILabel = {
        let joinLabel1 = UILabel()
        joinLabel1.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "加",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        return joinLabel1
    }()
    lazy var joinLabel2: UILabel = {
        let joinLabel2 = UILabel()
        joinLabel2.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "入遊戲",
            size: 20,
            textColor: .B3 ?? .black,
            letterSpacing: 10)
        return joinLabel2
    }()
    lazy var invitationTextFileld: BaseTextField = {
        let invitationTextFileld = BaseTextField()
        invitationTextFileld.placeholder = "請輸入邀請碼"
        invitationTextFileld.textAlignment = .center
        return invitationTextFileld
    }()
    lazy var goButton: BaseButton = {
        let goButton = BaseButton()
        goButton.setAttributedTitle(UIFont.fontStyle(
            font: .regular,
            title: "GO!",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5), for: .normal)
        goButton.titleLabel?.textAlignment = .center
        goButton.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
        return goButton
    }()
    let dataBase = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        [logoImage, createRoomButton, joinLabel1, joinLabel2, invitationTextFileld, goButton].forEach { view.addSubview($0) }
        logoImage.snp.makeConstraints { make in
            make.top.equalTo(view).offset(200)
            make.centerX.equalTo(view)
            make.width.equalTo(130)
            make.height.equalTo(130)
        }
        createRoomButton.snp.makeConstraints { make in
            make.top.equalTo(logoImage.snp.bottom).offset(30)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        joinLabel1.snp.makeConstraints { make in
            make.top.equalTo(view.snp.centerY).offset(50)
            make.right.equalTo(view.snp.centerX).offset(-25)
        }
        joinLabel2.snp.makeConstraints { make in
            make.centerY.equalTo(joinLabel1)
            make.left.equalTo(joinLabel1.snp.right).offset(2)
        }
        invitationTextFileld.snp.makeConstraints { make in
            make.top.equalTo(joinLabel1.snp.bottom).offset(20)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        goButton.snp.makeConstraints { make in
            make.top.equalTo(invitationTextFileld.snp.bottom).offset(30)
            make.centerX.equalTo(view)
            make.width.equalTo(75)
            make.height.equalTo(40)
        }
    }
    @objc func createRoomButtonPressed() {
        let settingVC = SettingViewController()
        navigationController?.pushViewController(settingVC, animated: true)
    }
    @objc func goButtonPressed() {
        let room = dataBase.collection("Rooms")
        let documentRef = room.document(invitationTextFileld.text ?? "")
        UserDefaults.standard.setValue(invitationTextFileld.text, forKey: "roomId")
        documentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if var players = document.data()?["player"] as? [String] {
                    guard let email = Auth.auth().currentUser?.email else {
                        print("Email is missing")
                        return
                    }
                    players.append(email)
                    // 計算玩家的index
                    let playerIndex = players.count - 1
                    documentRef.setData([
                        "player": players,
                        "playerIndex": playerIndex // 存入玩家的index
                    ], merge: true) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                        } else {
                            print("Document updated successfully")
                            // 取回自己的index及對應的題目
                            documentRef.getDocument { (document, error) in
                                if let document = document, let playerIndex = document.data()?["playerIndex"] as? Int, let prompts = document.data()?["prompts"] as? [String] {
                                    self.handlePlayerIndex(playerIndex, prompts)
                                } else {
                                    print("Failed to retrieve player index: \(error?.localizedDescription ?? "")")
                                }
                            }
                            self.invitationTextFileld.text = ""
                            let waitingVC = WaitingViewController()
                            self.navigationController?.pushViewController(waitingVC, animated: true)
                        }
                    }
                }
            } else {
                print("Document does not exist or there was an error: \(error?.localizedDescription ?? "")")
            }
        }
    }
    func handlePlayerIndex(_ playerIndex: Int, _ prompts: [String]) -> String? {
        guard playerIndex >= 0 && playerIndex < prompts.count else {
            print("Invalid player index")
            return nil
        }
        let selectedPrompt = prompts[playerIndex]
        UserDefaults.standard.removeObject(forKey: "hostPrompt")
        UserDefaults.standard.removeObject(forKey: "playerPrompt")
        UserDefaults.standard.setValue(selectedPrompt, forKey: "playerPrompt")
        print(UserDefaults.standard.string(forKey: "playerPrompt")!)
        print("Selected plyer prompt: \(selectedPrompt)")
        return selectedPrompt
    }
}
