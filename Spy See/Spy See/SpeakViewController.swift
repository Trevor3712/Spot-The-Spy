//
//  SpeakViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/17.
//

import UIKit
import FirebaseFirestore

class SpeakViewController: UIViewController {
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var clueLabel: UILabel!
    @IBOutlet weak var clueTextView: UITextView!
    var players: [String] = []
    var currentPlayerIndex: Int = 0
//    var initialPlayerIndex: Int = 0
    var timer: Timer?
    let dataBase = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let storedPlayers = UserDefaults.standard.stringArray(forKey: "playersArray") {
            players = storedPlayers
        }
//        currentPlayerIndex = Int.random(in: 0..<players.count)
//        initialPlayerIndex = currentPlayerIndex
        showNextPrompt()
        showClue()
    }
    func showNextPrompt() {
        guard currentPlayerIndex < players.count else {
            return
        }
        promptLabel.text = "\(players[currentPlayerIndex])請發言"
        currentPlayerIndex += 1
        print(currentPlayerIndex)
        if currentPlayerIndex == players.count {
            timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
                self?.performSegue(withIdentifier: "SpeakToVote", sender: self)
                self?.timer?.invalidate()
            }
            return
        }
//        if currentPlayerIndex >= players.count {
//            currentPlayerIndex = 0
//        }
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            self?.showNextPrompt()
        }
    }
    @IBAction func giveClue(_ sender: UIButton) {
        let room = dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        let data: [String: Any] = [
            "clue": clueTextView.text ?? ""
        ]
        documentRef.updateData(data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
                self.clueTextView.text = ""
            }
        }
    }
    func showClue() {
        let room = dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        documentRef.addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                print(error)
                return
            }
            guard let data = documentSnapshot?.data() else {
                print("No data available")
                return
            }
            if let clue = data["clue"] as? String {
                DispatchQueue.main.async {
                    self.clueLabel.text = clue
                } 
            } else {
                DispatchQueue.main.async {
                    self.clueLabel.text = ""
                }
            }
        }
    }
}
extension SpeakViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SpeakToVote" {
            
        }
    }
}