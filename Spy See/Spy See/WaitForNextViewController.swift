//
//  WaitForNextViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class WaitForNextViewController: UIViewController {
    let dataBase = Firestore.firestore()
    var readyListener: ListenerRegistration?
    let currentPlayers = UserDefaults.standard.stringArray(forKey: "playersArray")
    var readyPlayers: [String] = []
    let currentUser = Auth.auth().currentUser?.email ?? ""
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readtToGO()
        loadReadyPlayer()
    }
    func readtToGO() {
        let room = self.dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        documentRef.updateData(["playersReady": FieldValue.arrayUnion([currentUser])]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document updated successfully")
            }
        }
    }
    func loadReadyPlayer() {
        let room = self.dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        var existingPlayers: Set<String> = Set(self.readyPlayers)
        readyListener = documentRef.addSnapshotListener { (documentSnapshot, error) in
            DispatchQueue.main.async {
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error)")
                    return
                }
                let playersReady = document.data()?["playersReady"] as? [String] ?? []
                self.readyPlayers = []
                let newPlayers = playersReady.filter { !existingPlayers.contains($0) }
                self.readyPlayers.append(contentsOf: newPlayers)
                if self.isAllPlayersReady() {
                    self.readyListener?.remove()
                    documentRef.updateData(["playersReady": []])
                    self.performSegue(withIdentifier: "NextToSpeak", sender: self)
                }
            }
        }
    }
    func isAllPlayersReady() -> Bool {
       print(self.currentPlayers)
       print(self.readyPlayers.count)
        return self.readyPlayers.count == self.currentPlayers?.count
   }
}
extension WaitForNextViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NextToSpeak" {
        }
    }
}
