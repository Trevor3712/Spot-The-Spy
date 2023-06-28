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
            font: .semibold,
            title: "建立遊戲",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5), for: .normal)
        createRoomButton.titleLabel?.textAlignment = .center
        createRoomButton.addTarget(self, action: #selector(createRoomButtonPressed), for: .touchUpInside)
        return createRoomButton
    }()
    lazy var joinLabel: UILabel = {
        let joinLabel = UILabel()
        joinLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "加入遊戲",
            size: 20,
            textColor: .B4 ?? .black,
            letterSpacing: 10)
        return joinLabel
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
            font: .semibold,
            title: "GO!",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 5), for: .normal)
        goButton.titleLabel?.textAlignment = .center
        goButton.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
        return goButton
    }()
    let dataBase = Firestore.firestore()
    var userName: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        [
            logoImage,
            createRoomButton,
            joinLabel,
            invitationTextFileld,
            goButton].forEach { view.addSubview($0) }
        logoImage.snp.makeConstraints { make in
            make.top.equalTo(view).offset(200)
            make.left.equalTo(view).offset(50)
            make.width.equalTo(130)
            make.height.equalTo(130)
        }
        createRoomButton.snp.makeConstraints { make in
            make.top.equalTo(logoImage.snp.bottom).offset(30)
            make.centerX.equalTo(logoImage)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        joinLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.centerY).offset(50)
            make.right.equalTo(view).offset(-55)
        }
        invitationTextFileld.snp.makeConstraints { make in
            make.top.equalTo(joinLabel.snp.bottom).offset(20)
            make.centerX.equalTo(joinLabel)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        goButton.snp.makeConstraints { make in
            make.top.equalTo(invitationTextFileld.snp.bottom).offset(30)
            make.centerX.equalTo(joinLabel)
            make.width.equalTo(75)
            make.height.equalTo(40)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserName()
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
                    guard let name = self.userName else {
                        print("Name is missing")
                        return
                    }
                    players.append(name)
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
                                    UserDefaults.standard.removeObject(forKey: "userName")
                                    UserDefaults.standard.setValue(self.userName, forKey: "userName")
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
        return selectedPrompt
    }
    func getUserName() {
        let room = dataBase.collection("Users")
        guard let userId = Auth.auth().currentUser?.email else {
            return
        }
        let documentRef = room.document(userId)
        documentRef.getDocument { (document, error) in
            if let document = document, let name = document.data()?["name"] as? String {
                self.userName = name
                print(self.userName)
            } else {
                print("Failed to retrieve player index: \(error?.localizedDescription ?? "")")
            }
        }
    }
}
