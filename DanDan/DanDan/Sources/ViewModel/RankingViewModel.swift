//
//  RankingViewModel.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

import Foundation

@MainActor
class RankingViewModel: ObservableObject {
    @Published var conquestStatuses: [ZoneConquestStatus] = []
    
    private let navigationManager = NavigationManager.shared
    
    /// 주어진 점수 배열을 기반으로 각 구역의 점령 상태를 계산하여 업데이트합니다.
    /// - Parameter scores: 구간별 팀 점수 정보 배열
    func updateConquestStatuses(with scores: [ZoneScore]) {
        conquestStatuses = ZoneScore.evaluatePerZone(scores: scores)
    }
    
    /// 메인 화면으로 이동합니다.
    func tapMainButton() {
        navigationManager.popToRoot()
    }
}
