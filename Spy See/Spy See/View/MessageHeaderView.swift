//
//  MessageHeaderCell.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/30.
//

import UIKit

class MessageHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = String(describing: MessageHeaderView.self)
    lazy var titleLabel = UILabel()
    override init(reuseIdentifier: String?) {
        super .init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.centerX.equalTo(contentView)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
