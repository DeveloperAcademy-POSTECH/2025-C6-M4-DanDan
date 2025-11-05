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

    // TODO: 더미 데이터 - 현재 유저
    var currentUserId: UUID = UUID(
        uuidString: "22222222-2222-2222-2222-222222222222"
    )!

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
    /// 선택된 필터 값에 따라 랭킹 아이템 목록을 반환합니다.
    /// - Parameters:
    ///     - items: 전체 랭킹 아이템 배열
    ///     - filter: "전체" 또는 "우리팀"
    ///     - myUserId: 현재 사용자 ID
    /// - Returns: 필터링된 랭킹 아이템 배열
    func filteredRankingItems(
    from items: [RankingItemData],
    filter: String,
    myUserId: UUID
    ) -> [RankingItemData] {
        guard filter == "우리 팀",
              let myTeam = items.first(where: { $0.id == myUserId })?.userTeam
        else {
            return items
        }
        return items.filter { $0.userTeam == myTeam }
    }
}

// MARK: - View 전용 모델 및 데이터 변환

extension RankingViewModel {

    // 뷰 전용 단순 데이터
    struct RankingItemData: Identifiable {
        let id: UUID
        let ranking: Int
        let userName: String
        let userImage: UIImage?
        let userWeekScore: Int
        let userTeam: String
        let backgroundColor: Color

        init(
            id: UUID = UUID(),
            ranking: Int,
            userName: String,
            userImage: UIImage?,
            userWeekScore: Int,
            userTeam: String,
            backgroundColor: Color
        ) {
            self.id = id
            self.ranking = ranking
            self.userName = userName
            self.userImage = userImage
            self.userWeekScore = userWeekScore
            self.userTeam = userTeam
            self.backgroundColor = backgroundColor
        }
    }

    /// 사용자 상태 배열(rankedUsers)을 바탕으로 뷰에 필요한 사용자 정보와 스타일 데이터를 구성하여 반환합니다.
    /// - Returns: [RankingItemData] 형식의 배열 (UserStatus, UserInfo, 스타일 포함)
    func getRankingItemDataList() -> [RankingItemData] {
        rankedUsers.compactMap { status in
            guard let info = userInfo.first(where: { $0.id == status.id })
            else { return nil }

            let image: UIImage? = info.userImage.first.flatMap {
                UIImage(data: $0)
            }

            let color: Color
            
            switch status.userTeam.lowercased() {
            case "blue": color = .subA20
            case "yellow": color = .subB20
            default: color = .gray5
            }

            return RankingItemData(
                id: info.id,
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
        vm.rankingItems = vm.getRankingItemDataList()  // 내부 상태 기반 자동 생성

        return vm
    }
}
