//
//  RankingView.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

struct RankingView: View {
    @StateObject private var viewModel = RankingViewModel()

    @State private var isRightSelected: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            SegmentedControl(
                leftTitle: "팀",
                rightTitle: "개인",
                frameMaxWidth: .infinity,
                isRightSelected: $isRightSelected
            )

            if isRightSelected {
                PersonalRankView(
                    rankingItems: viewModel.rankingItems,
                    myUserId: viewModel.currentUserId,
                    rankingFilter: viewModel.filteredRankingItems,
                    fetchRanking: viewModel.fetchRanking,
                    myRankDiff: viewModel.myRankDiff ?? 0,
                    myTeamRankDiff: viewModel.myTeamRankDiff ?? 0
                )
            } else {
                TeamRankView(
                    fetchTeamRanking: viewModel.fetchTeamRanking,
                    fetchMyRanking: viewModel.fetchMyRanking,
                    userTeamName: viewModel.myRanking?.teamName ?? "",
                    teamRankings: viewModel.teamRankings
                )
            }
        }
        .padding(.top, 45)
    }
}

#Preview {
    RankingView()
}
