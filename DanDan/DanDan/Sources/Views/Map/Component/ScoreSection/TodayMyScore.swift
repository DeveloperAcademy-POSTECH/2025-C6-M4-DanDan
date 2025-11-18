//
//  TodayMyScore.swift
//  DanDan
//
//  Created by soyeonsoo on 11/4/25.
//

import SwiftUI

struct TodayMyScore: View {
    var score: Int
    @State private var pulse: Bool = false
    @State private var showLottie: Bool = false

    private var teamSparkLottieName: String {
        TeamAssetProvider.sparkLottieName(for: StatusManager.shared.userStatus.userTeam)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Text("오늘 내 점수")
                    .font(.PR.caption5)
                    .foregroundStyle(.gray1)
                    .padding(.top, 4)

                Text("\(score)")
                    .font(.PR.title2)
                    .foregroundStyle(.steelBlack)
                    .scaleEffect(pulse ? 1.08 : 1.0)
                    .animation(.spring(response: 0.28, dampingFraction: 0.7), value: pulse)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        )
                    )
                    .id(score)
            }
            .animation(.spring(response: 0.28, dampingFraction: 0.9), value: score)
            
            if showLottie {
                LottieOnceView(
                    name: teamSparkLottieName,
                    contentMode: .scaleAspectFit,
                    holdProgress: 0.95
                ) {
                    showLottie = false
                }
                .allowsHitTesting(false)
                .offset(y: 50)
                .scaleEffect(0.2)
            }
        }
        .frame(width: 86, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 14, x: 0, y: 8)
        )
        .onReceive(NotificationCenter.default.publisher(for: ZoneConquerActionHandler.didUpdateScoreNotification)) { _ in
            pulse = true
            showLottie = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                pulse = false
            }
        }
    }
}

#Preview {
    TodayMyScore(score: 3)
}
