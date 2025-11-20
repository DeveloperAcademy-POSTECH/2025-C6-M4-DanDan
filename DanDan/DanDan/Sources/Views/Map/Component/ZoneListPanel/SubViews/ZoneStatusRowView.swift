//
//  ZoneStatusRow.swift
//  DanDan
//
//  Created by Jay on 11/20/25.
//

import SwiftUI

struct ZoneStatusRowView: View {
    let zone: ZoneStatusDetail
    
    var body: some View {
        HStack {
            Text("\(zone.id)구역")
                .font(.PR.body4)
                .foregroundStyle(.darkGreen)
                .padding(.trailing, 12)
            
            Text("\(zone.zoneName)")
                .font(.PR.body4)
                .foregroundStyle(.gray1)
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("파랑 노랑")
                    .font(.PR.caption5)
                    .foregroundColor(.steelBlack)
                
                Text("\(zone.teamScores[0].totalScore) : \(zone.teamScores[1].totalScore)")
                    .font(.PR.caption5)
                    .foregroundColor(.steelBlack)
            }
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 22)
        .background(zone.leadingTeamName == "Blue" ? .subA20: .subB20)
        .cornerRadius(12)
    }
}
