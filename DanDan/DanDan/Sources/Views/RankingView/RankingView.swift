//
//  RankingView.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

struct RankingView: View {
    @StateObject var viewModel = RankingViewModel()

    var body: some View {
        VStack {
            List(viewModel.conquestStatuses) { status in
                Text("Zone \(status.zoneId): \(status.teamName ?? "무승부")")
            }

            Button {
                viewModel.tapMainButton()
            } label: {
                Text("홈")
            }
        }
        .padding()
    }
}

#Preview {
    let previewViewModel = RankingViewModel()
    let dummyScores: [ZoneScore] = [
        ZoneScore(zoneId: 1, teamId: 1, teamName: "Team A", teamScore: 5),
        ZoneScore(zoneId: 1, teamId: 2, teamName: "Team B", teamScore: 3),
        ZoneScore(zoneId: 2, teamId: 1, teamName: "Team A", teamScore: 2),
        ZoneScore(zoneId: 2, teamId: 2, teamName: "Team B", teamScore: 2),
        ZoneScore(zoneId: 3, teamId: 2, teamName: "Team B", teamScore: 7),
    ]
    previewViewModel.updateConquestStatuses(with: dummyScores)

    return RankingView(viewModel: previewViewModel)
}
