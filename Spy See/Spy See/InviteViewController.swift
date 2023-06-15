//
//  InviteViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/15.
//

import UIKit

class InviteViewController: UIViewController {
    @IBOutlet weak var inviteLabel: UILabel!
    var roomId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        guard roomId != nil else {
            return
        }
        inviteLabel.text = roomId
    }
    @IBAction func joinRoom(_ sender: UIButton) {
    }
}
