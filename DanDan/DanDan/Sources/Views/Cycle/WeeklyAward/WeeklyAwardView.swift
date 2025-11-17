//
//  WeeklyAwardView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import SwiftUI

struct WeeklyAwardView: View {
    @StateObject private var viewModel = WeeklyAwardViewModel()
    
    var body: some View {
        VStack {
            WeeklyAwardTitleSectionView(
                title: viewModel.winnerTitle,
                description: "총 \(viewModel.winningTeam?.conqueredZones ?? 0)구역을 점령했어요"
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
                "새로운 게임 시작하기",
                action: {
                    viewModel.tapNewGameButton()
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
