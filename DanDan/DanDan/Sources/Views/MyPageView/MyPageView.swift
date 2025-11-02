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
            ProfileHeader {
                viewModel.tapProfileEditButton()
            }
            
            WeeklyActivityCard()

            HistoryCardButton {
                viewModel.tapSeasonHistoryButton()
            }

            Spacer()
        }
    }
}

#Preview {
    MyPageView()
}
