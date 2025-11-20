//
//  ZoneStatusRow.swift
//  DanDan
//
//  Created by Jay on 11/20/25.
//

import SwiftUI

struct ZoneStatusRowView: View {
    let zone: ZoneStatusTest
    
    var body: some View {
        HStack {
            Text("\(zone.id)구역")
                .font(.PR.body4)
                .foregroundStyle(.darkGreen)
                .padding(.trailing, 12)
            
            Text("\(zone.name)")
                .font(.PR.body4)
                .foregroundStyle(.gray1)
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("파랑 노랑")
                    .font(.PR.caption5)
                    .foregroundColor(.steelBlack)
                
                Text("\(zone.blueScore) : \(zone.yellowScore)")
                    .font(.PR.caption5)
                    .foregroundColor(.steelBlack)
            }
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 22)
        .background(.subA20)
        .cornerRadius(12)
    }
}

#Preview {
    ZoneStatusRowView(
        zone: ZoneStatusTest(
            id: 1,
            name: "상생누리길 1",
            blueScore: 73,
            yellowScore: 23
        )
    )
}
