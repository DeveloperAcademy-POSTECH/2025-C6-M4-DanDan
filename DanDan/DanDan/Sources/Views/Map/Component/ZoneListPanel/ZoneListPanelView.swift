//
//  ZoneStatusBottomSheetView.swift
//  DanDan
//
//  Created by Jay on 11/20/25.
//

import SwiftUI

struct ZoneListPanelView: View {

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(sampleZones) { zone in
                    ZoneStatusRowView(zone: zone)
                }
            }
        }
        .frame(maxHeight: .infinity)   // 원하는 높이로 조절 가능
    }
}

#Preview {
    ZoneListPanelView()
}


struct ZoneStatusTest: Identifiable {
    let id: Int
    let name: String
    let blueScore: Int
    let yellowScore: Int
}

let sampleZones: [ZoneStatusTest] = [
    .init(id: 1, name: "상생누리길 1", blueScore: 73, yellowScore: 23),
    .init(id: 2, name: "상생누리길 2", blueScore: 16, yellowScore: 23),
    .init(id: 3, name: "상생누리길 3", blueScore: 17, yellowScore: 23),
]
