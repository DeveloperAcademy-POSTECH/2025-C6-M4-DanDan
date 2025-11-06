//
//  RankingViewModel.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

import Combine
import Foundation
import SwiftUI
import UIKit

@MainActor
class RankingViewModel: ObservableObject {
    @Published var conquestStatuses: [ZoneConquestStatus] = []
    @Published var userInfo: [UserInfo] = []
    @Published var rankedUsers: [UserStatus] = []
    
    // TODO: 팀명 확정 후 수정
    @Published var teams: [Team] = [
        Team(id: UUID(), teamName: "Blue", teamColor: "A"),
        Team(id: UUID(), teamName: "Yellow", teamColor: "B")
    ]
    
    @Published var rankingItems: [RankingItemData] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let rankingService = RankingService.shared
    private let rankingManager = RankingManager.shared
    private let navigationManager = NavigationManager.shared

    // TODO: 더미 데이터 - 현재 유저
    var currentUserId: UUID = UUID(
        uuidString: "6699BDBD-46AA-49B7-AB77-4B2BB985E8CC"
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
}

// MARK: 백엔드 연동

extension RankingViewModel {

    /// 서버에서 완성된 랭킹 데이터를 그대로 받아 ViewModel 상태를 업데이트합니다.
    func fetchRanking() {
        isLoading = true

        rankingService.fetchOverallRanking()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false

                switch completion {
                case .finished:
                    print("성공")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] dtoList in
                guard let self else { return }

                // ✅ 성공 시 데이터 확인 로그
                print("✅ [Ranking Fetch Success] DTO Count:", dtoList.count)
                dtoList.forEach { dto in
                    print(
                        " - \(dto.ranking)위 \(dto.userName) (\(dto.userTeam)) / 점수: \(dto.userWeekScore)"
                    )
                }

                /// DTO → 내부 UI 모델 변환 + 팀 색상 지정
                self.rankingItems = dtoList.map { dto in
                    // 팀 색상 설정
                    let color: Color
                    switch dto.userTeam.lowercased() {
                    case "blue":
                        color = .subA20
                    case "yellow":
                        color = .subB20
                    default:
                        color = .gray5
                    }
                    
                    return RankingItemData(
                        id: dto.id,
                        ranking: dto.ranking,
                        userName: dto.userName,
                        userImage: nil,  // 나중에 AsyncImage로 교체 가능
                        userWeekScore: dto.userWeekScore,
                        userTeam: dto.userTeam,
                        backgroundColor: color
                    )
                }
            }
            .store(in: &cancellables)
    }
}
