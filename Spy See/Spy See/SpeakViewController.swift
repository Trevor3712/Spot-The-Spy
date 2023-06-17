//
//  SpeakViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/17.
//

import UIKit

class SpeakViewController: UIViewController {
    @IBOutlet weak var promptLabel: UILabel!
    var players: [String] = []
    var currentPlayerIndex: Int = 0
//    var initialPlayerIndex: Int = 0
    var timer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let storedPlayers = UserDefaults.standard.stringArray(forKey: "playersArray") {
            players = storedPlayers
        }
//        currentPlayerIndex = Int.random(in: 0..<players.count)
//        initialPlayerIndex = currentPlayerIndex
        showNextPrompt()
    }
    func showNextPrompt() {
        guard currentPlayerIndex < players.count else {
            return
        }
        promptLabel.text = "\(players[currentPlayerIndex])請發言"
        currentPlayerIndex += 1
        print(currentPlayerIndex)
        if currentPlayerIndex == players.count - 1 {
            timer?.invalidate()
            return
        }
//        if currentPlayerIndex >= players.count {
//            currentPlayerIndex = 0
//        }
        timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: false) {[weak self] _ in
            self?.showNextPrompt()
        }
    }
}
