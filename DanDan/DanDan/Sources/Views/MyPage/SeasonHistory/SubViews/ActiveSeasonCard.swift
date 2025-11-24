//
//  ActiveSeasonCard.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

import SwiftUI

struct ActiveSeasonCard: View {
    @ObservedObject var viewModel: SeasonHistoryViewModel
    @State private var highlightedZoneIdsFromAPI: Set<Int> = []
    @State private var isLoadingZoneScores: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.weekLabel)
                        .font(.PR.body2)
                        .foregroundStyle(.steelBlack)
                    Text(viewModel.weekRange)
                        .font(.PR.caption4)
                        .foregroundStyle(.gray2)
                }
                Spacer()
                StatusTag(text: viewModel.statusText)
            }
            .padding(.bottom, 16)

            RemainingProgressBar(
                progress: viewModel.progress,
                trailingText: viewModel.remainingText
            )
            .padding(.bottom, 32)

            // TODO: 자신의 현재 팀 아이콘으로 설정
            HStack(spacing: 0) {
                Image(viewModel.currentTeamName.lowercased() == "blue" ? "train_R_blue" : "train_R_yellow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                Spacer()
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("거리")
                            .font(.PR.body4)
                            .foregroundStyle(.gray2)
                        HStack(spacing: 0){
                            Text(String(format: "%.1f", viewModel.currentDistanceKm))
                                .font(.PR.title2)
                                .foregroundStyle(.steelBlack)
                            Text("km")
                                .font(.PR.body2)
                                .foregroundStyle(.steelBlack)
                        }
                    }
                    VStack(spacing: 8) {
                        Text("점수")
                            .font(.PR.body4)
                            .foregroundStyle(.gray2)
                        Text("\(viewModel.currentWeekScore)점")
                            .font(.PR.title2)
                            .foregroundStyle(.steelBlack)
                    }
                    VStack(spacing: 8) {
                        Text("팀 내 순위")
                            .font(.PR.body4)
                            .foregroundStyle(.gray2)
                        Text("\(viewModel.currentTeamRank)위")
                            .font(.PR.title2)
                            .foregroundStyle(.steelBlack)
                    }
                }
            }
            .padding(.bottom, 28)

            Text("내가 얻은 구역")
                .font(.pretendard(.semiBold, size: 14))
                .foregroundStyle(.gray2)
                .padding(.bottom, 8)

            AcquiredZonesMapView(
                highlightedZoneIds: highlightedZoneIdsFromAPI,
                highlightColor: {
                    let team = StatusManager.shared.userStatus.userTeam.lowercased()
                    return team == "blue" ? .subA : .subB
                }()
            )
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primaryGreen, lineWidth: 2)
        )
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .task {
            await loadZoneScores()
        }
    }
}

// RemainingProgressBar는 별도 파일로 분리됨
//
// #Preview {
//    ActiveSeasonCard(viewModel: SeasonHistoryViewModel(autoRefresh: false))
// }

private extension ActiveSeasonCard {
    func loadZoneScores() async {
        if isLoadingZoneScores { return }
        isLoadingZoneScores = true
        defer { isLoadingZoneScores = false }
        do {
            let data = try await SeasonHistoryService.shared.fetchUserZoneScoresAsync(periodId: nil)
            let ids = data.zoneScores
                .filter { $0.totalScore > 0 }
                .map(\.zoneId)
            highlightedZoneIdsFromAPI = Set(ids)
        } catch {
            let dict = StatusManager.shared.userStatus.zoneCheckedStatus
            let fallbackIds = dict.compactMap { $0.value ? $0.key : nil }
            highlightedZoneIdsFromAPI = Set(fallbackIds)
            print("❌ Failed to load user zone-scores: \(error)")
        }
    }
}

