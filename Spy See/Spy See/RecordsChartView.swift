//
//  RecordsChartView.swift
//  Spot The Spy
//
//  Created by 楊哲維 on 2023/7/7.
//

import SwiftUI
import Charts

struct RecordsCount: Identifiable {
    var type: String
    var count: Int
    var id = UUID()
}
struct RecordsData: Identifiable {
    var type: String
    var data: [RecordsCount]
    var id = UUID()
}
struct RecordsChartView: View {
    var spyWin: Int?
    var spyLose: Int?
    var normalWin: Int?
    var normalLose: Int?
//    @State private var animatedRecordsData: [RecordsData] = recordsData
    var body: some View {
        var winData = [
            RecordsCount(type: "平民", count: normalWin ?? 0),
            RecordsCount(type: "臥底", count: spyWin ?? 0)
        ]
        var loseData = [
            RecordsCount(type: "平民", count: normalLose ?? 0),
            RecordsCount(type: "臥底", count: spyLose ?? 0)
        ]
        let recordsData = [
            RecordsData(type: "Win", data: winData),
            RecordsData(type: "Lose", data: loseData)
        ]
        let maxValue = max(winData.max(by: { $0.count < $1.count })?.count ?? 0,
                                   loseData.max(by: { $0.count < $1.count })?.count ?? 0)
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
//        .onAppear {
//            for (index,_) in animatedRecordsData[0].data.enumerated() {
//                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
//                    withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)) {
//                        animatedRecordsData[index].data[0].animate = true
//                    }
//                }
//            }
//        }
        .padding()
    }
}
