//
//  WeeklyAwardViewModel.swift
//  DanDan
//
//  Created by Jay on 11/10/25.
//

import Foundation

@MainActor
class WeeklyAwardViewModel: ObservableObject {
    @Published var winningTeam: WinningTeam?
    @Published var topContributors: [Contributor] = []
    @Published var errorMessage: String?
    @Published var winnerTitle: String = ""

    private let navigationManager = NavigationManager.shared
    private let service = CycleService.shared
    
    /// 메인뷰로 이동합니다.
    func tapMainButton() {
        navigationManager.replaceRoot(with: .main)
    }

    /// 서버에서 받은 기여자 리스트를 MVP 뷰용으로 변환합니다.
    var mvpList: [MVP] {
        topContributors.map { contributor in
            MVP(
                rank: contributor.rankInTeam,
                imageName: contributor.profileUrl ?? "default_avatar"
            )
        }
    }

    /// 최근 완료된 점령 결과를 서버에서 가져옵니다.
    func fetchConquestResults() async {
        do {
            let result = try await service.fetchLatestCompletedResults()

            winningTeam = result.winningTeam

            switch winningTeam?.teamName.lowercased() {
            case "blue":
                winnerTitle = "세명고 우승!"
            case "yellow":
                winnerTitle = "대동중 X 이동고 우승!"
            default:
                winnerTitle = "비겼습니다!"
            }

            topContributors = result.topContributors

        } catch {
            errorMessage = "결과를 불러오는 중 오류가 발생했습니다."
        }
    }
}
