//
//  WeeklyAwardView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import Lottie
import SwiftUI

struct WeeklyAwardView: View {
    @StateObject private var viewModel = WeeklyAwardViewModel()
    @State private var isAnimationFinished = false
    
    private var trophyAnimationName: String {
        switch viewModel.winningTeam?.teamName.lowercased() {
        case "blue":
            return "trophy_blue_win"
        case "yellow":
            return "trophy_yellow_win"
        default:
            return "trophy_blue_win"
        }
    }
    
    var body: some View {
        ZStack {
            // 애니메이션이 끝난 후 나타나는 UI
            if isAnimationFinished {
                VStack {
                    WeeklyAwardTitleSectionView(
                        title: viewModel.winnerTitle,
                        description: "총 \(viewModel.winningTeam?.conqueredZones ?? 0)구역을 점령했어요"
                    )
                    .frame(maxWidth: .infinity, alignment: .top)
                    
                    Spacer()
                    
                    MVPsView(mvps: viewModel.mvpList)
                        .padding(.bottom, 20)
                    
                    PrimaryButton(
                        "새로운 게임 시작하기",
                        action: {
                            viewModel.tapNewGameButton()
                            GamePhaseManager.shared.showWeeklyAward = false
                        }
                    )
                }
                .padding()
                .transition(.opacity)
                .task {
                    await viewModel.fetchConquestResults()
                }
            }
        }
        // confetti + trophy
        .background(
            LottieOnceView(
                name: trophyAnimationName,
                onCompleted: {
                    withAnimation(.easeOut(duration: 0.4)) {
                        isAnimationFinished = true
                    }
                }
            )
            .offset(y: -110)
            .ignoresSafeArea()
            .scaleEffect(0.35)
        )
        // light effect
        .background(
            LottieLoopView(name: "trophy_light_effect")
                .offset(y: -90)
                .ignoresSafeArea()
                .opacity(isAnimationFinished ? 1 : 0)
        )
    }
}

#Preview {
    WeeklyAwardView()
}
