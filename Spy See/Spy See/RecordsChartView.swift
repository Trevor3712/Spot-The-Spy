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
    var body: some View {
        var winData = [
            RecordsCount(type: "平民", count: 10),
            RecordsCount(type: "臥底", count: 6)
        ]
        var loseData = [
            RecordsCount(type: "平民", count: 4),
            RecordsCount(type: "臥底", count: 3)
        ]
        let recordsData = [
            RecordsData(type: "Win", data: winData),
            RecordsData(type: "Lose", data: loseData)
        ]
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
        .chartYAxis{
            AxisMarks(position: .trailing)
        }
        .chartForegroundStyleScale([
            "Win": Color(hue: 0.10, saturation: 0.70, brightness: 0.90),
            "Lose": Color(hue: 0.80, saturation: 0.70, brightness: 0.80)
        ])
    }
}

//struct RecordsChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecordsChartView()
//    }
//}
