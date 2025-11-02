//
//  RankingViewModel.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
class RankingViewModel: ObservableObject {
    @Published var conquestStatuses: [ZoneConquestStatus] = []
    @Published var userInfo: [UserInfo] = []
    @Published var rankedUsers: [UserStatus] = []
    @Published var rankingItems: [RankingItemData] = []

    private let navigationManager = NavigationManager.shared
    private let rankingManager = RankingManager.shared

    /// 주어진 점수 배열을 기반으로 각 구역의 점령 상태를 계산하여 업데이트합니다.
    /// - Parameter scores: 구간별 팀 점수 정보 배열
    func updateConquestStatuses(with scores: [ZoneScore]) {
        conquestStatuses = ZoneScore.evaluatePerZone(scores: scores)
    }

    /// 전체 사용자 상태 배열을 받아, 주간 점수를 기준으로 순위를 계산해 'rankedUsers'에 반영합니다.
    /// - Parameter users: 모든 사용자들의 주간 상태를 담은 배열
    func updateRanking(from users: [UserStatus]) {
        rankedUsers = rankingManager.assignRanking(to: users)
    }

    /// 메인 화면으로 이동합니다.
    func tapMainButton() {
        navigationManager.popToRoot()
    }
}


extension RankingViewModel {

            case "blue": color = .blue.opacity(0.1)
            case "yellow": color = .yellow.opacity(0.1)
            default: color = .gray.opacity(0.1)
            return RankingItemData(
                ranking: status.rank,
                userName: info.userName,
                userImage: image,
                userWeekScore: status.userWeekScore,
                userTeam: status.userTeam,
                backgroundColor: color
            )
        }
    }
}

// TODO: 더미데이터 수정
extension RankingViewModel {
    static var dummy: RankingViewModel {
        let vm = RankingViewModel()

        vm.rankedUsers = UserStatus.dummyStatuses
        vm.userInfo = UserInfo.dummyUsers
        vm.rankingItems = vm.getRankingItemDataList() // 내부 상태 기반 자동 생성

        return vm
    }
}

