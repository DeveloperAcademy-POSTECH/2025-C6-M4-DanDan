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
    RankingView(viewModel: {
        let vm = RankingViewModel()
        var dummyScores: [ZoneScore] = []

        var s1 = ZoneScore(zoneId: 1)
        s1.teamId = 1; s1.teamName = "Team A"; s1.teamScore = 5
        dummyScores.append(s1)

        var s2 = ZoneScore(zoneId: 1)
        s2.teamId = 2; s2.teamName = "Team B"; s2.teamScore = 3
        dummyScores.append(s2)

        var s3 = ZoneScore(zoneId: 2)
        s3.teamId = 1; s3.teamName = "Team A"; s3.teamScore = 2
        dummyScores.append(s3)

        var s4 = ZoneScore(zoneId: 2)
        s4.teamId = 2; s4.teamName = "Team B"; s4.teamScore = 2
        dummyScores.append(s4)

        var s5 = ZoneScore(zoneId: 3)
        s5.teamId = 2; s5.teamName = "Team B"; s5.teamScore = 7
        dummyScores.append(s5)

        vm.updateConquestStatuses(with: dummyScores)
        return vm
    }())
}
