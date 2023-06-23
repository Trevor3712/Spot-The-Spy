//
//  ViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/14.
//

import UIKit
import FirebaseAuth
import SnapKit

class LoginViewController: UIViewController {
    @IBOutlet weak var account: UITextField!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func logIn(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: account.text ?? "", password: password.text ?? "") { _, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            print("\(self.account.text ?? "") log in")
            let lobbyVC = LobbyViewController()
//            self.navigationController?.pushViewController(lobbyVC, animated: true)
        }
    }
}
