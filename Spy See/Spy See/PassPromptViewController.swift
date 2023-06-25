//
//  PassPromptViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/16.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PassPromptViewController: BaseViewController {
    @IBOutlet weak var promptLabel: UILabel!
    var playerPrompt: String?
    let dataBase = Firestore.firestore()
    var readyPlayers: [String] = []
    var playerNumber: Int?
    var documentListener: ListenerRegistration?
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let playerPrompt = UserDefaults.standard.string(forKey: "playerPrompt")
            let hostPrompt = UserDefaults.standard.string(forKey: "hostPrompt")
            if playerPrompt != nil {
                self.promptLabel.text = playerPrompt
            } else {
                self.promptLabel.text = hostPrompt
            }
        }
        loadReadyPlayers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        documentListener?.remove()
    }
    @IBAction func readyButtonPressed(_ sender: UIButton) {
        let room = self.dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        guard let email = Auth.auth().currentUser?.email else {
            print("Email is missing")
            return
        }
        documentRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error retrieving document: \(error)")
                return
            }
            guard let document = documentSnapshot, document.exists else {
                print("Document does not exist")
                return
            }
            var playersReady = document.data()?["playersReady"] as? [String] ?? []
            if !playersReady.contains(email) {
                playersReady.append(email)
            }
            let data: [String: Any] = [
                "playersReady": playersReady
            ]
            documentRef.updateData(data) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document updated successfully")
                }
            }
        }
    }
    func loadReadyPlayers() {
        let room = self.dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        var existingPlayers: Set<String> = Set(self.readyPlayers)
        documentListener = documentRef.addSnapshotListener { (documentSnapshot, error) in
            DispatchQueue.main.async {
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error)")
                    return
                }
                if let players = document.data()?["player"] as? [String] {
                    self.playerNumber = players.count
                }
                let playersReady = document.data()?["playersReady"] as? [String] ?? []
                self.readyPlayers = []
                let newPlayers = playersReady.filter { !existingPlayers.contains($0) }
                self.readyPlayers.append(contentsOf: newPlayers)
                if self.isAllPlayersReady() {
                    documentRef.updateData(["playersReady": []])
                    self.performSegue(withIdentifier: "PromptToSpeak", sender: self)
                }
            }
        }
    }
    func isAllPlayersReady() -> Bool {
        print("playerNumber\(Int(playerNumber ?? 0))")
        print("readyPlayers:\(self.readyPlayers.count)")
        return self.readyPlayers.count == playerNumber
    }
}

extension PassPromptViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PromptToSpeak" {
        }
    }
}
