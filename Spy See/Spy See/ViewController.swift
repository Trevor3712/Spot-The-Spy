//
//  ViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/14.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var account: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func check(_ sender: UIButton) {
        
        if let user = Auth.auth().currentUser {
            print("\(user.uid) login")
        } else {
            print("not login")
        }
        
    }
    
    @IBAction func logIn(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: account.text ?? "", password: password.text ?? "") { result, error in
             guard error == nil else {
                 print(error?.localizedDescription ?? "")
                return
             }
            print("\(self.account.text ?? "") log in")
        }
        
    }
}

