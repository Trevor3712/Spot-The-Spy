//
//  RecordsChartView.swift
//  Spot The Spy
//
//  Created by 楊哲維 on 2023/7/7.
//

import SwiftUI
import Charts

private struct RecordsCount: Identifiable {
    var type: String
    var count: Int
    var id = UUID()
}
private struct RecordsData: Identifiable {
    var type: String
    var data: [RecordsCount]
    var id = UUID()
}
struct RecordsChartView: View {
    var spyWin: Int?
    var spyLose: Int?
    var normalWin: Int?
    var normalLose: Int?
    var body: some View {
        let winData = [
            RecordsCount(type: "平民", count: normalWin ?? 0),
            RecordsCount(type: "臥底", count: spyWin ?? 0)
        ]
        let loseData = [
            RecordsCount(type: "平民", count: normalLose ?? 0),
            RecordsCount(type: "臥底", count: spyLose ?? 0)
        ]
        let recordsData = [
            RecordsData(type: "Win", data: winData),
            RecordsData(type: "Lose", data: loseData)
        ]
        let maxValue = max(
            winData.max { $0.count < $1.count }?.count ?? 0,
            loseData.max { $0.count < $1.count }?.count ?? 0
        )
        Chart(recordsData, id: \.type) { records in
            ForEach(records.data) {
                let count = $0.count
                BarMark(
                    x: .value("身份", $0.type),
                    y: .value("場數", $0.count)
                )
                .foregroundStyle(by: .value("身份", records.type))
                .annotation(position: .overlay, alignment: .top, spacing: 5) {
                    Text("\(count)")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
                .position(by: .value("身份", records.type))
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing)
        }
        .chartForegroundStyleScale([
            "Win": Color(UIColor.Y ?? .black).gradient,
            "Lose": Color(UIColor.R ?? .black).gradient
        ])
        .chartYScale(domain: 0...maxValue)
        .padding()
    }
}
