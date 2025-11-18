//
//  ConquestPhaseManager.swift
//  DanDan
//
//  Created by soyeonsoo on 11/8/25.
//

import SwiftUI
import Combine

@MainActor
final class GamePhaseManager: ObservableObject {
    static let shared = GamePhaseManager()
    @Published var showWeeklyAward = false
    private init() {}
    
    /// 서버에서 현재 Period를 조회하고 종료되었으면 어워드 뷰로 전환
    func checkWeeklyAwardCondition() async {
        do {
            let dto = try await CycleService.shared.requestCurrentPeriod()
            
            let formatter = ISO8601DateFormatter()
            guard let endDate = formatter.date(from: dto.endDate) else { return }
            
            let now = Date()
            
            // 오늘 날짜가 endDate 이후라면 → 어워드 시작
            if now > endDate {
                DispatchQueue.main.async {
                    self.showWeeklyAward = true
                }
            }
        } catch {
            print("❌ Period 조회 실패: \(error)")
        }
    }
}
