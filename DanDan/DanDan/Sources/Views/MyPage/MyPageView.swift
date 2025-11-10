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
                winCount: viewModel.winCount,
                totalScore: viewModel.totalScore
            )
            
//            ProfileHeader(viewModel: viewModel) {
//                viewModel.tapProfileEditButton()
//            }
            
            WeeklyActivityCard(viewModel: viewModel)

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

#Preview {
    MyPageView()
}
