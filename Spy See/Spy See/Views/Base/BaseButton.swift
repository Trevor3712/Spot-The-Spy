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
        backgroundColor = .B2
        layer.borderWidth = 1
        layer.borderColor = UIColor.B1?.cgColor
        layer.cornerRadius = 5
        layer.shadowColor = UIColor.B3?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
