//
//  SettingViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/15.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import CryptoKit

class SettingViewController: UIViewController {
    @IBOutlet weak var playerNumber: UITextField!
    @IBOutlet weak var spyNumber: UITextField!
    let dataBase = Firestore.firestore()
    var promptArray: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    @IBAction func createInvationCode(_ sender: UIButton) {
        let room = dataBase.collection("Rooms")
        let roomId = generateRoomId()
        let documentRef = room.document(roomId)
        let data: [String: Any] = [
            "prompts": generatePromptArray(),
            "player": String(describing: Auth.auth().currentUser)
        ]
        documentRef.setData(data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
            }
        }
    }
    func generateRoomId() -> String {
        let inviteCodeLength = 4
        let fullCode = UUID().uuidString
        let hash = SHA256.hash(data: fullCode.data(using: .utf8)!)
        let hashedString = hash.compactMap { String(format: "%02x", $0) }.joined()
        let roomId = String(hashedString.prefix(inviteCodeLength))
        return roomId
    }
    func generatePromptArray() -> [String] {
        promptArray = []
        let choosedPrompt = prompt.randomElement()
        for _ in 0...(Int(playerNumber.text ?? "") ?? 0) - (Int(spyNumber.text ?? "") ?? 0) - 1 {
            promptArray.append(choosedPrompt?.0 ?? "")
        }
        for _ in 0...(Int(spyNumber.text ?? "") ?? 0) - 1 {
            promptArray.append(choosedPrompt?.1 ?? "")
        }
        promptArray.shuffle()
        return promptArray
    }
}
