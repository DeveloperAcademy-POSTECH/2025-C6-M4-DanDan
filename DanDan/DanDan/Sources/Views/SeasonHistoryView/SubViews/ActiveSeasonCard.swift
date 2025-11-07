//
//  ActiveSeasonCard.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

import SwiftUI

struct ActiveSeasonCard: View {
    @ObservedObject var viewModel: SeasonHistoryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.weekLabel)
                        .font(.PR.body2)
                    Text(viewModel.weekRange)
                        .font(.PR.caption4)
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

            HStack(spacing: 0) {
                Image(systemName: "flag.fill")
                    .font(.system(size: 48, weight: .bold))
                Spacer()
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("거리")
                            .font(.PR.body4)
                        Text("\(Int(viewModel.currentDistanceKm))km")
                            .font(.PR.title2)
                    }
                    VStack(spacing: 8) {
                        Text("점수")
                            .font(.PR.body4)
                        Text("\(viewModel.currentWeekScore)")
                            .font(.PR.title2)
                    }
                    VStack(spacing: 8) {
                        Text("팀 내 순위")
                            .font(.PR.body4)
                        Text("\(viewModel.currentTeamRank)위")
                            .font(.PR.title2)
                    }
                }
            }
            .padding(.bottom, 28)
            
            Text("내가 얻은 구역")
                .padding(.bottom, 8)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.yellow)
                .frame(height: 157)
            
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green, lineWidth: 2)
        )
        .padding(.horizontal, 20)
        .padding(.top, 40)
    }
}

// RemainingProgressBar는 별도 파일로 분리됨
//
//#Preview {
//    ActiveSeasonCard(viewModel: SeasonHistoryViewModel(autoRefresh: false))
//}
