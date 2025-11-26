//
//  ZoneInfoView.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/15/25.
//

import SwiftUI

struct ZoneInfoView: View {
    let zone: Zone
    let teamScores: [ZoneTeamScoreDTO]

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                ZoneInfoScore(teamScores: teamScores)
                ZoneInfoDescription(
                    descriptionText: zone.description
                )
            }
            .padding(.horizontal, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZoneInfoTitle(zoneId: zone.zoneId, zoneName: zone.zoneName,  distance: zone.distance,)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray3)
                    }
                }
            }
        }
        .presentationDetents([.fraction(0.20)])
        .presentationDragIndicator(.visible)
    }
}



#if DEBUG
#Preview {
    ZoneInfoView(
        zone: zones.first!,
        teamScores: [
            .init(teamId: "A", teamName: "블루팀", totalScore: 1200),
            .init(teamId: "B", teamName: "옐로우팀", totalScore: 980)
        ]
    )
}
#endif
