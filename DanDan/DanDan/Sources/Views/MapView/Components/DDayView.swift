//
//  DDayView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/3/25.
//

import Combine
import SwiftUI

struct DDayView: View {
    let period: ConquestPeriod
    var now: () -> Date = { Date() }   // 테스트/프리뷰 주입 용
    @State private var cancellable: AnyCancellable?
    
    @ObservedObject private var gamePhase = GamePhaseManager.shared
    
    // 게임 종료까지 남은 일수 계산
    private var daysRemaining: Int {
        let cal = Calendar.current
        let todayStartOfDay = cal.startOfDay(for: now())
        let endOfWeek   = cal.startOfDay(for: period.endDate)
        return max(0, cal.dateComponents([.day], from: todayStartOfDay, to: endOfWeek).day ?? 0)
    }
    
    private var ddayText: String {
        daysRemaining == 0 ? "D-Day" : "D-\(daysRemaining)"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("경기 종료까지")
                .font(.PR.body4)
                .foregroundStyle(.gray1)
            
            Text(ddayText)
                .font(.PR.title2)
                .foregroundStyle(.steelBlack)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 22)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 14, x: 0, y: 8)
        )
        .fixedSize()
        .onAppear { startChecking() }
    }
    
    private func startChecking() {
        cancellable = Timer.publish(every: 60, on: .main, in: .common) // 1분마다 체크
            .autoconnect()
            .sink { _ in
                let remaining = daysRemaining
                // 점령전이 끝나면 WeeklyAwardView로 이동
                if remaining <= 0 {
                    gamePhase.showWeeklyAward = true
                    cancellable?.cancel()
                }
            }
    }
}

//#Preview {
//    let start = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
//    let period = ConquestPeriod(startDate: start, durationInDays: 7)
//
//    DDayView(period: period)
//        .padding(.top, 8)
//        .padding(.leading, 20)
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//
//}
