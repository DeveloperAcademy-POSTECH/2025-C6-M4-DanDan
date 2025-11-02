//
//  MainViewModel.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    
    private let statusManager = StatusManager.shared
    private let userManager = UserManager.shared
    private let zoneScoreManager = ZoneScoreManager.shared
    private let navigationManager = NavigationManager.shared
    private let conquestResultManager = ConquestResultManager.shared
    private let rankingManager = RankingManager.shared

    // TODO: 구간 지나감 로직 구현 시 수정 필요
    let zoneId: Int = 1

    /// 오늘 이 구간에서 점수를 아직 안 얻었으면 버튼을 보여준다
    var shouldShowScoreButton: Bool {
        return statusManager.userStatus.zoneCheckedStatus[zoneId] != true
    }

    /// 랭킹 페이지로 이동합니다.
    func tapRankingButton() {
        navigationManager.navigate(to: .ranking)
    }

    /// 구역에 따른 점수 획득 로직을 처리합니다.
    func handleScoreButtonTapped(zoneId: Int) {
        statusManager.incrementDailyScore()
        statusManager.setZoneChecked(zoneId: zoneId, checked: true)
    }
    
    /// 현재 점령 기간이 종료되면 전체 게임 상태를 초기화하고 새로운 점령 기간을 생성합니다.
    /// - Parameters:
    ///   - currentPeriod: 현재 점령전 기간 정보
    ///   - zones: 현재 모든 구간의 점령 상태 배열
    func checkAndHandleConquestEnd(currentPeriod: ConquestPeriod, zones: [ZoneConquestStatus]) {
        guard currentPeriod.hasEnded else { return }
        
        statusManager.resetUserStatus()
        statusManager.resetZoneConquestStatus()
        zoneScoreManager.resetZoneScore()
        statusManager.startNewConquestPeriod()
    }
}
