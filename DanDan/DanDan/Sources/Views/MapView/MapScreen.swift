//
//  MapScreen.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import SwiftUI

struct MapScreen: View {
    @StateObject private var viewModel = MapScreenViewModel()

    let conquestStatuses: [ZoneConquestStatus]
    let teams: [Team]
    let userStatus: UserStatus
    let period: ConquestPeriod
    let refreshToken: UUID

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 3D 부분 지도
            MapView(
                conquestStatuses: conquestStatuses,
                teams: teams,
                refreshToken: refreshToken
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    if viewModel.teams.count >= 2 {
                        ScoreBoardView(
                            leftTeamName: viewModel.teams[0].teamName,
                            rightTeamName: viewModel.teams[1].teamName,
                            leftTeamScore: viewModel.teams[0].conqueredZones,
                            rightTeamScore: viewModel.teams[1].conqueredZones
                        )
                    } else {
                        // 로딩 중일 때는 기본값 표시
                        ScoreBoardView(
                            leftTeamName: "—",
                            rightTeamName: "—",
                            leftTeamScore: 0,
                            rightTeamScore: 0
                        )
                    }

                    TodayMyScore(score: viewModel.userDailyScore)  // 오늘 내 점수
                }

                if !viewModel.startDate.isEmpty {
                    DDayView(
                        dday: ConquestPeriod.from(
                            endDateString: viewModel.endDate
                        ),
                        period: period
                    )
                    .padding(.leading, 4)
                }
            }
            .padding(.top, 60)
            .padding(.leading, 14)
        }
        .task {
            await viewModel.loadMapInfo()
        }
    }
}
