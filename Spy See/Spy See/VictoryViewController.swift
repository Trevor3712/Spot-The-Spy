//
//  VictoryViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/18.
//

import UIKit

class VictoryViewController: UIViewController {
//    @IBOutlet weak var victoryLabel: UILabel!
    lazy var victoryLabel = UILabel()
    var isSpyWin: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        whoWins()
        configureVictoryLabel()
    }
    @IBAction func backToHome(_ sender: UIButton) {
    }
    func whoWins() {
        if isSpyWin {
            victoryLabel.text = "臥底獲勝！"
        } else {
            victoryLabel.text = "平民獲勝！"
        }
    }
    func configureVictoryLabel() {
        view.addSubview(victoryLabel)
        victoryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            victoryLabel.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 100),
            victoryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
