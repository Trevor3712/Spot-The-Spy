//
//  SettingViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/15.
//

import UIKit
import FirebaseFirestore
import CryptoKit

class SettingViewController: UIViewController {
    @IBOutlet weak var playerNumber: UITextField!
    @IBOutlet weak var spyNumber: UITextField!
    let dataBase = Firestore.firestore()
    let promptArray: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    @IBAction func createInvationCode(_ sender: UIButton) {
        let room = dataBase.collection("Room")
        let documentRef = room.document()
        
        let roomId = generateRoomId()
        
        let data: [String: Any] = [
            "roomId": roomId,
            
            
        
        
        ]
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
        let choosedPrompt = prompt.randomElement()
        
    }
}
