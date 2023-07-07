//
//  RecordsViewController.swift
//  Spot The Spy
//
//  Created by 楊哲維 on 2023/7/6.
//

import UIKit
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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
    lazy var totalRecordsLabel: UILabel = {
        let totalRecordsLabel = UILabel()
        totalRecordsLabel.backgroundColor = .white
        totalRecordsLabel.layer.borderWidth = 1
        totalRecordsLabel.layer.borderColor = UIColor.B1?.cgColor
        totalRecordsLabel.layer.cornerRadius = 20
        totalRecordsLabel.clipsToBounds = true
        totalRecordsLabel.textAlignment = .center
        return totalRecordsLabel
    }()
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
    lazy var totalWinRateLabel: UILabel = {
        let totalWinRateLabel = UILabel()
        totalWinRateLabel.backgroundColor = .Y
        totalWinRateLabel.layer.borderWidth = 1
        totalWinRateLabel.layer.borderColor = UIColor.B1?.cgColor
        totalWinRateLabel.layer.cornerRadius = 20
        totalWinRateLabel.clipsToBounds = true
        totalWinRateLabel.textAlignment = .center
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
    lazy var normalLabel: UILabel = {
        let normalLabel = UILabel()
        normalLabel.backgroundColor = .white
        normalLabel.layer.borderWidth = 1
        normalLabel.layer.borderColor = UIColor.B1?.cgColor
        normalLabel.layer.cornerRadius = 20
        normalLabel.clipsToBounds = true
        normalLabel.textAlignment = .center
        normalLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "平民",
            size: 30,
            textColor: .B2 ?? .black,
            letterSpacing: 5)
        return normalLabel
    }()
    lazy var spyLabel: UILabel = {
        let spyLabel = UILabel()
        spyLabel.backgroundColor = .white
        spyLabel.layer.borderWidth = 1
        spyLabel.layer.borderColor = UIColor.B1?.cgColor
        spyLabel.layer.cornerRadius = 20
        spyLabel.clipsToBounds = true
        spyLabel.textAlignment = .center
        spyLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "臥底",
            size: 30,
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
    let dataBase = Firestore.firestore()
    var recordsChartView = RecordsChartView()
    private var hostingController: UIHostingController<RecordsChartView>?
    override func viewDidLoad() {
        super.viewDidLoad()
        hostingController = UIHostingController(rootView: recordsChartView)
        self.addChild(hostingController!)
        hostingController!.didMove(toParent: self)
        [titleLabel, totalRecordsLabel, winRateLabel, totalWinRateLabel,
         chartView, normalContainerView, spyContainerViwe].forEach { view.addSubview($0) }
        [normalLabel, normalRecordsLabel, normalWinRateLabel].forEach { normalContainerView.addSubview($0) }
        [spyLabel, spyRecordsLabel, spyWinRateLabel].forEach { spyContainerViwe.addSubview($0) }
        chartView.addSubview(hostingController!.view)
        chartView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.width.equalTo(350)
            make.height.equalTo(250)
        }
        hostingController?.view.snp.makeConstraints { make in
            make.edges.equalTo(chartView).inset(5)
        }
        winRateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(hostingController!.view.snp.top).offset(-30)
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
            make.width.equalTo(hostingController!.view)
            make.height.equalTo(50)
        }
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(totalRecordsLabel.snp.top).offset(-30)
            make.centerX.equalTo(view)
        }
        normalContainerView.snp.makeConstraints { make in
            make.top.equalTo(hostingController!.view.snp.bottom).offset(30)
            make.centerX.equalTo(view)
            make.width.equalTo(350)
            make.height.equalTo(50)
        }
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRecords()
    }
    func getRecords() {
        let room = dataBase.collection("Users")
        guard let userId = Auth.auth().currentUser?.email else {
            return
        }
        let documentRef = room.document(userId)
        documentRef.getDocument { [self] (document, error) in
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
            self.hostingController?.rootView.spyWin = self.spyWin
            self.hostingController?.rootView.spyLose = self.spyLose
            self.hostingController?.rootView.normalWin = self.normalWin
            self.hostingController?.rootView.normalLose = self.normalLose
        }
    }
    func showRecords() {
        normalRecordsLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "\(normalWin)W \(normalLose)L",
            size: 30,
            textColor: .white,
            letterSpacing: 5)
        spyRecordsLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "\(spyWin)W \(spyLose)L",
            size: 30,
            textColor: .white,
            letterSpacing: 5)
        let normalWinRate = Float(normalWin) / (Float(normalWin) + Float(normalLose)) * 100
        let roundedNormalWinRate = String(format: "%.0f", normalWinRate)
        normalWinRateLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: roundedNormalWinRate + "%",
            size: 30,
            textColor: .Y ?? .black,
            letterSpacing: 5)
        let spyWinRate = Float(spyWin) / (Float(spyWin) + Float(spyLose)) * 100
        let roundedSpyWinRate = String(format: "%.0f", spyWinRate)
        spyWinRateLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: roundedSpyWinRate + "%",
            size: 30,
            textColor: .Y ?? .black,
            letterSpacing: 5)
        let totalWin = normalWin + spyWin
        let totalLose = normalLose + spyLose
        totalRecordsLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "\(totalWin)W \(totalLose)L",
            size: 30,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        let totalGames = totalWin + totalLose
        let totalRecords = (Float(totalWin) / Float(totalGames) * 100)
        let roundedTotalRecords = String(format: "%.0f", totalRecords)
        totalWinRateLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: roundedTotalRecords + "%",
            size: 30,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
    }
}
