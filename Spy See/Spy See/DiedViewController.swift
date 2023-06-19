//
//  DiedViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/19.
//

import UIKit

class DiedViewController: UIViewController {
    
    lazy var diedLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(diedLabel)
        diedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            diedLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 300),
            diedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        diedLabel.text = "你已經死了！"
    }
    
}
