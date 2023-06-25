//
//  BaseButton.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/24.
//

import UIKit

class BaseButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.adjustsFontSizeToFitWidth = true
        backgroundColor = .B3
        layer.borderWidth = 1
        layer.borderColor = UIColor.B1?.cgColor
        layer.cornerRadius = 5
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}