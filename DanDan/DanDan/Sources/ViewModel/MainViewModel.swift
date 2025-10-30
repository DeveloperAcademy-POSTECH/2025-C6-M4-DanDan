//
//  MainViewModel.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    @ObservedObject var statusManager = StatusManager.shared
    @ObservedObject var userManager = UserManager.shared
    
    private let navigationManager = NavigationManager.shared
    private let conquestResultManager = ConquestResultManager.shared
    private let rankingManager = RankingManager.shared

    // TODO: 구간 지나감 로직 구현 시 수정 필요
    let zoneId: Int = 1

    /// 오늘 이 구간에서 점수를 아직 안 얻었으면 버튼을 보여준다
    var shouldShowScoreButton: Bool {
        return statusManager.userStatus.zoneCheckeStatus[zoneId] != true
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
}
