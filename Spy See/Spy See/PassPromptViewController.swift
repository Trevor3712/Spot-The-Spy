//
//  PassPromptViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/16.
//

import UIKit

class PassPromptViewController: UIViewController {
    @IBOutlet weak var promptLabel: UILabel!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let playerPrompt = UserDefaults.standard.string(forKey: "playerPrompt")
        let hostPrompt = UserDefaults.standard.string(forKey: "hostPrompt")
        print(playerPrompt)
        print(hostPrompt)
        if playerPrompt != nil {
            promptLabel.text = playerPrompt
        } else {
            promptLabel.text = hostPrompt
        }
    }
}
