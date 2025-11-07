//
//  MapScreen.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import SwiftUI

struct MapScreen: View {
    @StateObject private var viewModel = MapScreenViewModel()

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 3D 부분 지도
            MapView(conquestStatuses: [], teams: [])
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

                    TodayMyScore(
                        status: UserStatus(
                            userDailyScore: viewModel.userDailyScore
                        )
                    )  // 오늘 내 점수
                }

                if !viewModel.startDate.isEmpty {
                    DDayView(
                        dday: ConquestPeriod.from(
                            endDateString: viewModel.endDate
                        )
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

//#Preview {
//    // 더미 데이터
//    let teams = [
//        Team(id: UUID(), teamName: "Blue", teamColor: "A"),
//        Team(id: UUID(), teamName: "Yellow", teamColor: "B"),
//    ]
//
//    let statuses: [ZoneConquestStatus] = [
//        .init(zoneId: 1, teamId: 1, teamName: "Blue", teamScore: 7),
//        .init(zoneId: 1, teamId: 2, teamName: "Yellow", teamScore: 3),
//        .init(zoneId: 2, teamId: 1, teamName: "Blue", teamScore: 2),
//        .init(zoneId: 3, teamId: 2, teamName: "Yellow", teamScore: 9),
//    ]
//
//    var dummyStatus = UserStatus()
//    dummyStatus.userDailyScore = 5
//
//    let start = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
//    let period = ConquestPeriod(startDate: start, durationInDays: 7)
//
//    return MapScreen(
//        conquestStatuses: statuses,
//        teams: teams,
//        userStatus: dummyStatus,
//        period: period
//    )
//}
