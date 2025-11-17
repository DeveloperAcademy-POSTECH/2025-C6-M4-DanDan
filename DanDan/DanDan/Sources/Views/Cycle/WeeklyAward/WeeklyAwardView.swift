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
    
    var body: some View {
        ZStack {
            // 애니메이션이 끝난 후 나타나는 UI
            if isAnimationFinished {
                
                VStack {
                    WeeklyAwardTitleSectionView(
                        title: viewModel.winnerTitle,
                        description: "총 \(viewModel.winningTeam?.conqueredZones ?? 0)구역을 점령했어요\n테스트 참여 감사해요 더 좋은 앱으로 돌아올게요"
                    )
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .top)
                    
                    Spacer()
                    
                    MVPsView(mvps: viewModel.mvpList)
                    
                    PrimaryButton(
                        "그래도 스틸워크와 계속 걷기",
                        action: {
                            viewModel.tapMainButton()
                            GamePhaseManager.shared.showWeeklyAward = false
                        }
                    )
                }
                .padding()
                .transition(.opacity)
                .task {
                    await viewModel.fetchConquestResults()
                }
//                .background(
//                    LottieLoopView(name: "trophy_light_effect")
//                        .scaleEffect(0.35)
//                )
            }
        }
        .background(
            LottieOnceView(
                name: "trophy_blue_win",
                onCompleted: {
                    withAnimation(.easeOut(duration: 0.4)) {
                        isAnimationFinished = true
                    }
                }
            )
            .offset(y: -86)
            .ignoresSafeArea()
            .scaleEffect(0.35)
        )
    }
}

#Preview() {
    WeeklyAwardView()
}
