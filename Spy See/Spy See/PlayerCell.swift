//
//  PlayerCell.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/16.
//

import UIKit

class PlayerCell: UITableViewCell {
    static let reuseIdentifier = String(describing: PlayerCell.self)
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.layer.cornerRadius = 20
        titleLabel.clipsToBounds = true
        titleLabel.backgroundColor = .B3
        return titleLabel
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
