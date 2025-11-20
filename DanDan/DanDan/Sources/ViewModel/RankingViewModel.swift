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
    @Published var rankingItems: [RankingItemData] = []
    @Published var myTeamRankings: [MyTeamRankingData] = []
    @Published var myRanking: MyRankingData?
    @Published var myRankDiff: Int? = nil
    @Published var myTeamRankDiff: Int? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // TODO: 팀명 확정 후 수정
    @Published var teams: [Team] = [
        Team(id: UUID(), teamName: "북구팀", teamColor: "A"),
        Team(id: UUID(), teamName: "남구팀", teamColor: "B"),
    ]
    
    private var cancellables = Set<AnyCancellable>()
    private let rankingService = RankingService.shared
    private let rankingManager = RankingManager.shared
    private let navigationManager = NavigationManager.shared
    private let tokenManager = TokenManager()

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
    
    func teamOnlyRanking(from items: [RankingItemData], myUserId: UUID) -> [RankingItemData] {
        guard
            let myTeam = items.first(where: { $0.id == myUserId })?.userTeam
        else { return items }

        return items
            .filter { $0.userTeam == myTeam }
            .sorted { $0.ranking < $1.ranking }
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
    
    /// 현재 유저의 랭킹 정보를 가져옵니다.
    func fetchMyRanking() {
        Task {
            do {
                let myRanking = try await rankingService.requestMyRanking()
                self.myRanking = myRanking
            } catch {
                errorMessage = "유저 랭킹을 불러오지 못했습니다: \(error.localizedDescription)"
                print("❌ fetchMyRanking 실패: \(error)")
            }
        }
    }
    
    func fetchMyTeamRanking() {
        Task {
            do {
                let myTeamRankings = try await rankingService.requestMyTeamRanking()
                self.myTeamRankings = myTeamRankings
            } catch {
                errorMessage = "유저 랭킹을 불러오지 못했습니다: \(error.localizedDescription)"
                print("❌ fetchMyRanking 실패: \(error)")
            }
        }
    }
    
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
                
                if let myTeam = newRanking.first(where: { $0.id == self.currentUserId })?.userTeam {
                    
                    // 내 팀만 필터링
                    let teamRanking = newRanking.filter { $0.userTeam == myTeam }
                                        
                    // 팀 랭킹에서 내 위치 찾기
                    if let index = teamRanking.firstIndex(where: { $0.id == self.currentUserId }) {

                        let myTeamRank = index + 1

                        let prevTeamRank = self.loadMyPreviousTeamRank()

                        if let prevTeamRank {
                            self.myTeamRankDiff = prevTeamRank - myTeamRank
                        } else {
                            self.myTeamRankDiff = nil
                        }

                        self.saveMyPreviousTeamRank(myTeamRank)
                    }
                }

                self.rankingItems = newRanking
            }
            .store(in: &cancellables)
    }
}

// MARK: - UserDefaults 저장 및 불러오기

extension RankingViewModel {
    
    private func formattedToday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    /// 이전 내 순위를 UserDefaults에 저장합니다.
    private func saveMyPreviousRank(_ rank: Int) {
        let today = formattedToday()
        
        // 이미 오늘 저장된 값이 있으면 덮어쓰기 금지
        if let storedDate = UserDefaults.standard.string(forKey: "myPreviousRankDate"),
           storedDate == today {
            return
        }
        
        UserDefaults.standard.set(rank, forKey: "myPreviousRank")
        UserDefaults.standard.set(today, forKey: "myPreviousRankDate")
        UserDefaults.standard.set(currentUserId.uuidString, forKey: "myUserId")
    }

    /// 이전 내 순위를 UserDefaults에서 불러옵니다.
    private func loadMyPreviousRank() -> Int? {
        let today = formattedToday()
        
        // 날짜 체크 → 오늘 저장한 값이면 비교할 필요 없음
        guard let storedDate = UserDefaults.standard.string(forKey: "myPreviousRankDate"),
              storedDate != today else {
            return nil
        }
        
        // 유저 ID 체크 (다른 계정이면 무효)
        guard let savedId = UserDefaults.standard.string(forKey: "myUserId"),
              savedId == currentUserId.uuidString else {
            return nil
        }
        
        let rank = UserDefaults.standard.integer(forKey: "myPreviousRank")
        return rank == 0 ? nil : rank
    }
    
    /// 이전 내 팀내 순위를 UserDefaults에 저장합니다.
    private func saveMyPreviousTeamRank(_ rank: Int) {
        let today = formattedToday()
        let storedDate = UserDefaults.standard.string(forKey: "myPreviousTeamRankDate")
        
        // 이미 오늘 저장했다면 저장하지 않음 (중복 저장 방지)
        if storedDate == today { return }
        
        UserDefaults.standard.set(rank, forKey: "myPreviousTeamRank")
        UserDefaults.standard.set(today, forKey: "myPreviousTeamRankDate")
        UserDefaults.standard.set(currentUserId.uuidString, forKey: "myTeamRankUserId")
    }

    /// 이전 팀내 순위를 UserDefaults에서 불러옵니다.
    private func loadMyPreviousTeamRank() -> Int? {
        let today = formattedToday()
        guard let storedDate = UserDefaults.standard.string(forKey: "myPreviousTeamRankDate"),
              storedDate != today else {
            return nil
        }
        
        guard let savedId = UserDefaults.standard.string(forKey: "myTeamRankUserId"),
              savedId == currentUserId.uuidString else {
            return nil
        }
        
        let rank = UserDefaults.standard.integer(forKey: "myPreviousTeamRank")
        return rank == 0 ? nil : rank
    }
}
