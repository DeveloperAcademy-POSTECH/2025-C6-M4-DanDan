//
//  WeeklyAwardView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import SwiftUI

struct WeeklyAwardView: View {
    @StateObject private var viewModel = WeeklyAwardViewModel()
    
    private let navigationManager = NavigationManager.shared
    
    var body: some View {
        VStack {
            WeeklyAwardTitleSectionView(
                title: viewModel.winnerTitle,
                description: "총 \(viewModel.winningTeam?.conqueredZones ?? 0)구역을 점령했어요\n테스트 참여 감사해요 더 좋은 앱으로 돌아올게요"
            )
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .top)
            
            Image("trophy")
                .resizable()
                .scaledToFit()
                .frame(width: 230)
                .padding(.top, 20)
            
            MVPsView(mvps: viewModel.mvpList)

            
            Spacer()
            
            PrimaryButton(
                "그래도 스틸워크와 계속 걷기",
                action: {
                    navigationManager.replaceRoot(with: .main)
                    GamePhaseManager.shared.showWeeklyAward = false
                }
            )
        }
        .task {
            await viewModel.fetchConquestResults()
        }
    }
}

#Preview() {
    WeeklyAwardView()
}
