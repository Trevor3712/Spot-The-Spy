//
//  RecordsViewController.swift
//  Spot The Spy
//
//  Created by 楊哲維 on 2023/7/6.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RecordsViewController: BaseViewController {
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "你的戰績",
            size: 30,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        return titleLabel
    }()
    lazy var totalRecordsLabel = UILabel()
    lazy var winRateLabel: UILabel = {
        let winRateLabel = UILabel()
        winRateLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "勝率",
            size: 30,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        return winRateLabel
    }()
    lazy var totalWinRateLabel = UILabel()
    lazy var chartView = UIView()
    lazy var normalLabel: UILabel = {
        let normalLabel = UILabel()
        normalLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "平民",
            size: 30,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        return normalLabel
    }()
    lazy var spyLabel: UILabel = {
        let spyLabel = UILabel()
        spyLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "臥底",
            size: 30,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        return spyLabel
    }()
    lazy var normalRecordsLabel = UILabel()
    lazy var spyRecordsLabel = UILabel()
    lazy var normalWinRateLabel = UILabel()
    lazy var spyWinRateLabel = UILabel()
    var spyWin = 0
    var spyLose = 0
    var normalWin = 0
    var normalLose = 0
    let dataBase = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        [titleLabel, totalRecordsLabel, winRateLabel, totalWinRateLabel,
         chartView,
         normalLabel, spyLabel,
         normalRecordsLabel, spyRecordsLabel,
         normalWinRateLabel, spyWinRateLabel].forEach { view.addSubview($0) }
        chartView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.width.equalTo(320)
            make.height.equalTo(250)
        }
        chartView.backgroundColor = .white
        winRateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(chartView.snp.top).offset(-50)
            make.left.equalTo(chartView)
        }
        totalWinRateLabel.snp.makeConstraints { make in
            make.left.equalTo(winRateLabel.snp.right).offset(100)
            make.centerY.equalTo(winRateLabel)
        }
        totalWinRateLabel.text = "70%"
        totalRecordsLabel.snp.makeConstraints { make in
            make.bottom.equalTo(winRateLabel.snp.top).offset(-30)
            make.centerX.equalTo(view)
        }
        totalRecordsLabel.text = "15W  6L"
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(totalRecordsLabel.snp.top).offset(-50)
            make.centerX.equalTo(view)
        }
        normalLabel.snp.makeConstraints { make in
            make.top.equalTo(chartView.snp.bottom).offset(30)
            make.left.equalTo(chartView)
        }
        normalRecordsLabel.snp.makeConstraints { make in
            make.left.equalTo(normalLabel.snp.right).offset(50)
            make.centerY.equalTo(normalLabel)
        }
        normalRecordsLabel.text = "10W  2L"
        normalWinRateLabel.snp.makeConstraints { make in
            make.left.equalTo(normalRecordsLabel.snp.right).offset(50)
            make.centerY.equalTo(normalLabel)
        }
        normalWinRateLabel.text = "60%"
        spyLabel.snp.makeConstraints { make in
            make.top.equalTo(normalWinRateLabel.snp.bottom).offset(50)
            make.left.equalTo(normalLabel)
        }
        spyRecordsLabel.snp.makeConstraints { make in
            make.left.equalTo(spyLabel.snp.right).offset(50)
            make.centerY.equalTo(spyLabel)
        }
        spyRecordsLabel.text = "5W  3L"
        spyWinRateLabel.snp.makeConstraints { make in
            make.left.equalTo(spyRecordsLabel.snp.right).offset(50)
            make.centerY.equalTo(spyLabel)
        }
        spyWinRateLabel.text = "50%"
        getRecords()
//        showRecords()
    }
    func getRecords() {
        let room = dataBase.collection("Users")
        guard let userId = Auth.auth().currentUser?.email else {
            return
        }
        let documentRef = room.document(userId)
        documentRef.getDocument { (document, error) in
            guard let document = document else {
                return
            }
            if let normalWin = document.data()?["normalWin"] as? String {
                self.normalWin = Int(normalWin) ?? 0
            }
            if let normalLose = document.data()?["normalLose"] as? String {
                self.normalLose = Int(normalLose) ?? 0
            }
            if let spyWin = document.data()?["spyWin"] as? String {
                self.spyWin = Int(spyWin) ?? 0
            }
            if let spyLose = document.data()?["spyLose"] as? String {
                self.spyLose = Int(spyLose) ?? 0
            }
            self.showRecords()
        }
    }
    func showRecords() {
        normalRecordsLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "\(normalWin)W  \(normalLose)L",
            size: 30,
            textColor: .white,
            letterSpacing: 10)
        spyRecordsLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "\(spyWin)W \(spyLose)L",
            size: 30,
            textColor: .white,
            letterSpacing: 10)
        normalWinRateLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "\((Float(normalWin) / (Float(normalWin) + Float(normalLose)) * 100))%",
            size: 30,
            textColor: .white,
            letterSpacing: 10)
        spyWinRateLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "\((Float(spyWin) / (Float(spyWin) + Float(spyLose)) * 100))%",
            size: 30,
            textColor: .white,
            letterSpacing: 10)
        let totalWin = normalWin + spyWin
        let totalLose = normalLose + spyLose
        totalRecordsLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "\(totalWin)W \(totalLose)L",
            size: 30,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        let totalGames = totalWin + totalLose
        totalWinRateLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "\(Float(totalWin) / Float(totalGames) * 100)%",
            size: 30,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
    }
}
