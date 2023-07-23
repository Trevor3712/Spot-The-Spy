//
//  SpeakViewController+TableView.swift
//  Spot The Spy
//
//  Created by 楊哲維 on 2023/7/23.
//

import UIKit

extension SpeakViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            return clues.count
        } else {
            return messages.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MessageCell.reuseIdentifier) as? MessageCell else {
            fatalError("Can't create cell")
        }
        if tableView.tag == 1 {
            cell.backgroundColor = .B1
            cell.titleLabel.attributedText = UIFont.fontStyle(
                font: .regular,
                title: clues[indexPath.row],
                size: 20,
                textColor: .B4 ?? .black,
                letterSpacing: 0)
            return cell
        } else {
            cell.titleLabel.attributedText = UIFont.fontStyle(
                font: .regular,
                title: messages[indexPath.row],
                size: 20,
                textColor: .B2 ?? .black,
                letterSpacing: 0)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: MessageHeaderView.reuseIdentifier) as? MessageHeaderView else {
            fatalError("Can't create header")
        }
        if tableView.tag == 1 {
            header.titleLabel.attributedText = UIFont.fontStyle(
                font: .semibold,
                title: "- 線索 -",
                size: 20,
                textColor: .B4 ?? .black,
                letterSpacing: 10)
            return header
        } else {
            header.titleLabel.attributedText = UIFont.fontStyle(
                font: .semibold,
                title: "- 討論 -",
                size: 20,
                textColor: .B2 ?? .black,
                letterSpacing: 10)
            return header
        }
    }
}

extension SpeakViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let editingUrl = editingUrl else {
            return
        }
        playSeAudio(from: editingUrl)
    }
}
