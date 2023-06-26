//
//  BaseMessageTableView.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/26.
//

import UIKit

class BaseMessageTableView: UITableView {
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        backgroundColor = .white
        separatorStyle = .none
        layer.borderWidth = 1
        layer.borderColor = UIColor.B1?.cgColor
        layer.cornerRadius = 20
        clipsToBounds = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
