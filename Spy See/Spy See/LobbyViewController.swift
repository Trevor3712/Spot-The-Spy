//
//  LobbyViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/15.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LobbyViewController: UIViewController {
    @IBOutlet weak var invitationCode: UITextField!
    let dataBase = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    @IBAction func joinRoom(_ sender: UIButton) {
        let room = dataBase.collection("Rooms")
        let documentRef = room.document(invitationCode.text ?? "")
        UserDefaults.standard.setValue(invitationCode.text, forKey: "roomId")
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
                            self.invitationCode.text = ""
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
//        let passPromptVC = self.storyboard?.instantiateViewController(withIdentifier: "PassPromptViewController") as! PassPromptViewController
//        passPromptVC.playerPrompt = selectedPrompt
        UserDefaults.standard.removeObject(forKey: "hostPrompt")
        UserDefaults.standard.removeObject(forKey: "playerPrompt")
        UserDefaults.standard.setValue(selectedPrompt, forKey: "playerPrompt")
        print(UserDefaults.standard.string(forKey: "playerPrompt")!)
        print("Selected plyer prompt: \(selectedPrompt)")
        return selectedPrompt
    }
}
