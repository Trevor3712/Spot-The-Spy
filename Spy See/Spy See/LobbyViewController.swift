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
    @IBAction func logIn(_ sender: UIButton) {
    }
    @IBAction func joinRoom(_ sender: UIButton) {
        let room = dataBase.collection("Rooms")
        let documentRef = room.document(invitationCode.text ?? "")
        UserDefaults.standard.setValue(invitationCode.text, forKey: "roomId")
        documentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // 房间文档存在
                if var players = document.data()?["player"] as? [String] {
                    // 获取当前的玩家数组
                    guard let email = Auth.auth().currentUser?.email else {
                        print("Email is missing")
                        return
                    }
                    players.append(email)
                    documentRef.setData(["player": players], merge: true) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                        } else {
                            print("Document updated successfully")
//                            let waitingVC = WaitingViewController()
//                            self.navigationController?.pushViewController(waitingVC, animated: true)
                        }
                    }
                }
            } else {
                // 房间文档不存在或出错
                print("Document does not exist or there was an error: \(error?.localizedDescription ?? "")")
            }
        }
    }
}
