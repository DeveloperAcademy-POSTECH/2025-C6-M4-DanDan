//
//  MyPageView.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/1/25.
//

import SwiftUI

struct MyPageView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = MyPageViewModel()
    
    private var needsCustomBackButton: Bool {
        if #available(iOS 26.0, *) { return false } else { return true }
    }

    var body: some View {
        VStack(spacing: 0) {
            ProfileHeader(
                profileImage: viewModel.profileImage,
                displayName: viewModel.displayName,
                teamName: viewModel.teamRegionName,
                winCount: viewModel.winCount,
                totalScore: viewModel.totalScore,
                onTap: { viewModel.tapProfileEditButton() }
            )
            
            WeeklyActivityCard(
                currentWeekText: viewModel.currentWeekText,
                totalDistanceKm: viewModel.totalDistanceKmText,
                weekScore: viewModel.weekScore,
                teamRank: viewModel.teamRank,
                teamName: viewModel.teamName
                
            )

            HistoryCardButton {
                viewModel.tapSeasonHistoryButton()
            }

            Spacer()
        }
        .task {
            await viewModel.load()
        }
        .onAppear {
            Task { await viewModel.load() }
        }
    }
}

//#Preview {
//    MyPageView()
//}
