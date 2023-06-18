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
    var identityArray: [String] = []
    var shuffledIndices: [Int] = []
    var choosedPrompt: ([String], [String]) = ([], [])
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    @IBAction func createInvationCode(_ sender: UIButton) {
        let room = dataBase.collection("Rooms")
        let roomId = generateRoomId()
        UserDefaults.standard.setValue(roomId, forKey: "roomId")
        let documentRef = room.document(roomId)
        guard let email = Auth.auth().currentUser?.email else {
            print("Email is missing")
            return
        }
        let prompts = generatePromptArray()
        let identities = generateIdentityArray()
        let data: [String: Any] = [
            "prompts": prompts,
            "identities": identities,
            "player": [email],
            "playerNumber": playerNumber.text ?? ""
        ]
        documentRef.setData(data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
                UserDefaults.standard.removeObject(forKey: "playerPrompt")
                UserDefaults.standard.removeObject(forKey: "hostPrompt")
                UserDefaults.standard.setValue(self.promptArray[0], forKey: "hostPrompt")
                UserDefaults.standard.set(self.identityArray, forKey: "identities")
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
        choosedPrompt = prompt.randomElement() ?? ([""], [""])
        for _ in 0...(Int(playerNumber.text ?? "") ?? 0) - (Int(spyNumber.text ?? "") ?? 0) - 1 {
            promptArray.append(choosedPrompt.0[1])
        }
        for _ in 0...(Int(spyNumber.text ?? "") ?? 0) - 1 {
            promptArray.append(choosedPrompt.1[1])
        }
        shuffledIndices = Array(promptArray.indices).shuffled()
        promptArray = shuffledIndices.map { promptArray[$0] }
        return promptArray
    }
    func generateIdentityArray() -> [String] {
        identityArray = []
        for _ in 0...(Int(playerNumber.text ?? "") ?? 0) - (Int(spyNumber.text ?? "") ?? 0) - 1 {
            identityArray.append(choosedPrompt.0[0])
        }
        for _ in 0...(Int(spyNumber.text ?? "") ?? 0) - 1 {
            identityArray.append(choosedPrompt.1[0])
        }
        identityArray = shuffledIndices.map { identityArray[$0] }
        return identityArray
    }
}
