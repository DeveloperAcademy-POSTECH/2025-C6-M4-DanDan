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
    @Published var teamRankings: [TeamRanking] = []
    @Published var myRankDiff: Int? = nil

    // TODO: 팀명 확정 후 수정
    @Published var teams: [Team] = [
        Team(id: UUID(), teamName: "파랑팀", teamColor: "A"),
        Team(id: UUID(), teamName: "노랑팀", teamColor: "B"),
    ]

    @Published var rankingItems: [RankingItemData] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let rankingService = RankingService.shared
    private let rankingManager = RankingManager.shared
    private let navigationManager = NavigationManager.shared
    private let tokenManager = TokenManager()

    // TODO: 더미 데이터 - 현재 유저
    var currentUserId: UUID = UUID()

    init() {
        if let token = try? tokenManager.getAccessToken(),
            let userId = AccessTokenDecoder.extractUserId(from: token)
        {
            self.currentUserId = userId
            print("✅ currentUserId 세팅 완료: \(userId)")
        } else {
            print("⚠️ AccessToken에서 userId 추출 실패 — 게스트 상태")
        }
    }

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
        var userImage: UIImage?
        let userWeekScore: Int
        let userTeam: String
        let backgroundColor: Color
        var rankDiff: Int?

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

// MARK: - 팀 랭킹 서버 연동

extension RankingViewModel {
    func fetchTeamRanking() {
        Task {
            do {
                isLoading = true
                let rankings = try await rankingService.fetchTeamRankings()
                self.teamRankings = rankings
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = "팀 랭킹을 불러오지 못했습니다: \(error.localizedDescription)"
                print("❌ fetchTeamRanking 실패: \(error)")
            }
        }
    }
}

// MARK: - 개인 랭킹 서버 연동

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
                    print("✅ 랭킹 데이터 요청 완료")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("❌ 랭킹 요청 실패: \(error)")
                }
            } receiveValue: { [weak self] dtoList in
                guard let self else { return }

                // DTO → UI용 모델 변환
                let newRanking = dtoList.map { dto -> RankingItemData in
                    let item = RankingItemData(
                        id: dto.id,
                        ranking: dto.ranking,
                        userName: dto.userName,
                        userImage: nil,
                        userWeekScore: dto.userWeekScore,
                        userTeam: dto.userTeam,
                        backgroundColor: Color.setBackgroundColor(for: dto.userTeam)
                    )

                    // ✅ 비동기 이미지 로드
                    if let urlString = dto.userImage,
                       let url = URL(string: urlString) {
                        Task {
                            do {
                                let (data, _) = try await URLSession.shared.data(from: url)
                                if let image = UIImage(data: data) {
                                    await MainActor.run {
                                        if let index = self.rankingItems.firstIndex(where: { $0.id == dto.id }) {
                                            self.rankingItems[index].userImage = image
                                        }
                                    }
                                }
                            } catch {
                                print("⚠️ 이미지 로드 실패: \(error)")
                            }
                        }
                    }

                    return item
                }

                // ✅ 내 순위 비교 로직 (map 이후에!)
                if let myNewRank = newRanking.first(where: { $0.id == self.currentUserId })?.ranking {
                    let prevRank = self.loadMyPreviousRank()

                    if let prevRank {
                        let diff = prevRank - myNewRank
                        self.myRankDiff = diff
                    } else {
                        self.myRankDiff = nil
                    }

                    self.saveMyPreviousRank(myNewRank)
                }

                self.rankingItems = newRanking
            }
            .store(in: &cancellables)
    }
}

// MARK: - UserDefaults 저장 및 불러오기

extension RankingViewModel {
    /// 이전 내 순위를 UserDefaults에 저장합니다.
    private func saveMyPreviousRank(_ rank: Int) {
        UserDefaults.standard.set(rank, forKey: "myPreviousRank")
        UserDefaults.standard.set(currentUserId.uuidString, forKey: "myUserId")
    }

    /// 이전 내 순위를 UserDefaults에서 불러옵니다.
    private func loadMyPreviousRank() -> Int? {
        guard let savedId = UserDefaults.standard.string(forKey: "myUserId"),
              savedId == currentUserId.uuidString else {
            // 저장된 ID가 다르면 다른 계정 → 비교 무효
            return nil
        }
        let rank = UserDefaults.standard.integer(forKey: "myPreviousRank")
        return rank == 0 ? nil : rank
    }
}
