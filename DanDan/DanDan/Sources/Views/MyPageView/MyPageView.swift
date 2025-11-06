//
//  MyPageView.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/1/25.
//

import SwiftUI

struct MyPageView: View {
    @StateObject private var viewModel = MyPageViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ProfileHeader(viewModel: viewModel) {
                viewModel.tapProfileEditButton()
            }
            
            WeeklyActivityCard(viewModel: viewModel)

            HistoryCardButton {
                viewModel.tapSeasonHistoryButton()
            }

            Spacer()
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    MyPageView()
}
