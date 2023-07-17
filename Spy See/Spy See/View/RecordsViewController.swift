//
//  RecordsViewController.swift
//  Spot The Spy
//
//  Created by 楊哲維 on 2023/7/6.
//

import UIKit
import SwiftUI
import FirebaseAuth

class RecordsViewController: BaseViewController, ObservableObject {
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "你的戰績",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        return titleLabel
    }()
    lazy var totalRecordsLabel = BaseLabel()
    lazy var winRateLabel: UILabel = {
        let winRateLabel = UILabel()
        winRateLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "勝率",
            size: 25,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        return winRateLabel
    }()
    lazy var totalWinRateLabel: BaseLabel = {
        let totalWinRateLabel = BaseLabel()
        totalWinRateLabel.backgroundColor = .Y
        return totalWinRateLabel
    }()
    lazy var chartView: UIView = {
        let chartView = UIView()
        chartView.backgroundColor = .white
        chartView.layer.borderWidth = 1
        chartView.layer.borderColor = UIColor.B1?.cgColor
        chartView.layer.cornerRadius = 20
        chartView.clipsToBounds = true
        return chartView
    }()
    lazy var normalLabel: BaseLabel = {
        let normalLabel = BaseLabel()
        normalLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "平民",
            size: 25,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        return normalLabel
    }()
    lazy var spyLabel: BaseLabel = {
        let spyLabel = BaseLabel()
        spyLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "臥底",
            size: 25,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        return spyLabel
    }()
    lazy var normalRecordsLabel = UILabel()
    lazy var spyRecordsLabel = UILabel()
    lazy var normalWinRateLabel = UILabel()
    lazy var spyWinRateLabel = UILabel()
    lazy var normalContainerView = UIView()
    lazy var spyContainerViwe = UIView()
    var spyWin = 0
    var spyLose = 0
    var normalWin = 0
    var normalLose = 0
    var recordsChartView = RecordsChartView()
    private var hostingController: UIHostingController<RecordsChartView>?
    override func viewDidLoad() {
        super.viewDidLoad()
        hostingController = UIHostingController(rootView: recordsChartView)
        guard let hostingController = hostingController else {
            return
        }
        self.addChild(hostingController)
        hostingController.didMove(toParent: self)
        [titleLabel, totalRecordsLabel, winRateLabel, totalWinRateLabel].forEach { view.addSubview($0) }
        [chartView, normalContainerView, spyContainerViwe].forEach { view.addSubview($0) }
        [normalLabel, normalRecordsLabel, normalWinRateLabel].forEach { normalContainerView.addSubview($0) }
        [spyLabel, spyRecordsLabel, spyWinRateLabel].forEach { spyContainerViwe.addSubview($0) }
        chartView.addSubview(hostingController.view)
        chartView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.width.equalTo(350)
            make.height.equalTo(250)
        }
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalTo(chartView).inset(5)
        }
        winRateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(hostingController.view.snp.top).offset(-30)
            make.right.equalTo(view.snp.centerX).offset(-20)
        }
        totalWinRateLabel.snp.makeConstraints { make in
            make.left.equalTo(view.snp.centerX).offset(20)
            make.centerY.equalTo(winRateLabel)
            make.width.equalTo(130)
            make.height.equalTo(50)
        }
        totalRecordsLabel.snp.makeConstraints { make in
            make.bottom.equalTo(winRateLabel.snp.top).offset(-20)
            make.centerX.equalTo(view)
            make.width.equalTo(hostingController.view)
            make.height.equalTo(50)
        }
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(totalRecordsLabel.snp.top).offset(-30)
            make.centerX.equalTo(view)
        }
        normalContainerView.snp.makeConstraints { make in
            make.top.equalTo(hostingController.view.snp.bottom).offset(30)
            make.centerX.equalTo(view)
            make.width.equalTo(350)
            make.height.equalTo(50)
        }
        configureLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRecords()
    }
    func configureLayout() {
        normalLabel.snp.makeConstraints { make in
            make.top.equalTo(normalContainerView)
            make.left.equalTo(normalContainerView)
            make.width.equalTo(90)
            make.height.equalTo(50)
        }
        normalRecordsLabel.snp.makeConstraints { make in
            make.centerX.equalTo(normalContainerView)
            make.centerY.equalTo(normalLabel)
        }
        normalWinRateLabel.snp.makeConstraints { make in
            make.right.equalTo(chartView)
            make.centerY.equalTo(normalLabel)
        }
        spyContainerViwe.snp.makeConstraints { make in
            make.top.equalTo(normalContainerView.snp.bottom).offset(30)
            make.centerX.equalTo(view)
            make.width.equalTo(350)
            make.height.equalTo(50)
        }
        spyLabel.snp.makeConstraints { make in
            make.top.equalTo(spyContainerViwe)
            make.left.equalTo(spyContainerViwe)
            make.width.equalTo(90)
            make.height.equalTo(50)
        }
        spyRecordsLabel.snp.makeConstraints { make in
            make.centerX.equalTo(normalContainerView)
            make.centerY.equalTo(spyLabel)
        }
        spyWinRateLabel.snp.makeConstraints { make in
            make.right.equalTo(chartView)
            make.centerY.equalTo(spyLabel)
        }
    }
    func getRecords() {
        FirestoreManager.shared.getDocument(collection: "Users", key: "userEmail") { result in
            switch result {
            case .success(let document):
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
                self.showTotalRecords()
                self.showIdentityRecord()
                self.hostingController?.rootView.spyWin = self.spyWin
                self.hostingController?.rootView.spyLose = self.spyLose
                self.hostingController?.rootView.normalWin = self.normalWin
                self.hostingController?.rootView.normalLose = self.normalLose
            case .failure(let error):
                print("Error getting document:\(error)")
            }
        }
    }
}
extension RecordsViewController {
    func showTotalRecords() {
        let totalWin = normalWin + spyWin
        let totalLose = normalLose + spyLose
        totalRecordsLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "\(totalWin)勝 \(totalLose)敗",
            size: 25,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        let totalGames = totalWin + totalLose
        if totalGames != 0 {
            let totalRecords = (Float(totalWin) / Float(totalGames) * 100)
            let roundedTotalRecords = String(format: "%.0f", totalRecords)
            totalWinRateLabel.attributedText = UIFont.fontStyle(
                font: .semibold,
                title: roundedTotalRecords + "%",
                size: 25,
                textColor: .B2 ?? .black,
                letterSpacing: 10)
        } else {
            totalWinRateLabel.attributedText = UIFont.fontStyle(
                font: .semibold,
                title: "-",
                size: 25,
                textColor: .B2 ?? .black,
                letterSpacing: 10)
        }
    }
    func showIdentityRecord() {
        normalRecordsLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "\(normalWin)勝 \(normalLose)敗",
            size: 25,
            textColor: .white,
            letterSpacing: 5)
        spyRecordsLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "\(spyWin)勝 \(spyLose)敗",
            size: 25,
            textColor: .white,
            letterSpacing: 5)
        if normalWin != 0 && normalLose != 0 {
            let normalWinRate = Float(normalWin) / (Float(normalWin) + Float(normalLose)) * 100
            let roundedNormalWinRate = String(format: "%.0f", normalWinRate)
            normalWinRateLabel.attributedText = UIFont.fontStyle(
                font: .semibold,
                title: roundedNormalWinRate + "%",
                size: 25,
                textColor: .Y ?? .black,
                letterSpacing: 5)
        } else {
            normalWinRateLabel.attributedText = UIFont.fontStyle(
                font: .semibold,
                title: "-",
                size: 25,
                textColor: .Y ?? .black,
                letterSpacing: 5)
        }
        if spyWin != 0 && spyLose != 0 {
            let spyWinRate = Float(spyWin) / (Float(spyWin) + Float(spyLose)) * 100
            let roundedSpyWinRate = String(format: "%.0f", spyWinRate)
            spyWinRateLabel.attributedText = UIFont.fontStyle(
                font: .semibold,
                title: roundedSpyWinRate + "%",
                size: 25,
                textColor: .Y ?? .black,
                letterSpacing: 5)
        } else {
            spyWinRateLabel.attributedText = UIFont.fontStyle(
                font: .semibold,
                title: "-",
                size: 25,
                textColor: .Y ?? .black,
                letterSpacing: 5)
        }
    }
}
