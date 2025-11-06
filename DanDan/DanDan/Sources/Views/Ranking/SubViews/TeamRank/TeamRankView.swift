//
//  TeamRankView.swift
//  DanDan
//
//  Created by Jay on 11/2/25.
//

import SwiftUI

struct TeamRankView: View {
    let fetchTeamRanking: () -> Void
    let myUserId: UUID
    let teamRankings: [TeamRanking]

    var body: some View {
        VStack(spacing: 0) {
            TeamInstructionSectionView()
                .padding(.top, 45)

            TeamRankingListView(
                teamRankings: teamRankings,
                myUserId: myUserId
            )
            .padding(.top, 36)

            Spacer()
        }
        .onAppear {
            fetchTeamRanking()
        }
        .padding(.horizontal, 20)
    }
}

//#Preview {
//    TeamRankView(fetchTeamRanking: fetchTeamRanking)
//}
