//
//  PassPromptViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/16.
//

import UIKit

class PassPromptViewController: UIViewController {
    @IBOutlet weak var promptLabel: UILabel!
    var playerPrompt: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let playerPrompt = UserDefaults.standard.string(forKey: "playerPrompt")
            let hostPrompt = UserDefaults.standard.string(forKey: "hostPrompt")
            print(playerPrompt)
            print(hostPrompt)
            if playerPrompt != nil {
                self.promptLabel.text = playerPrompt
            } else {
                self.promptLabel.text = hostPrompt
            }
        }
    }
}
