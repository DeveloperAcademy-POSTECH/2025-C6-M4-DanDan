//
//  SeasonHistoryService.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/8/25.
//

import Combine
import Foundation

final class SeasonHistoryService {
    static let shared = SeasonHistoryService()

    private let network: NetworkService

    init(network: NetworkService = NetworkService()) {
        self.network = network
    }

    /// 유저 시즌 히스토리 조회 (최신순, 페이지네이션)
    func fetchUserHistory(page: Int = 1, size: Int = 5) -> AnyPublisher<SeasonHistoryDataDTO, NetworkError> {
        let endpoint = SeasonHistoryEndpoint.userHistory(page: page, size: size)
        return network
            .request(endpoint)
            .map { (response: SeasonHistoryAPIResponse) in response.data }
            .eraseToAnyPublisher()
    }

    /// async/await 버전 (MyPage 스타일)
    func fetchUserHistoryAsync(page: Int = 1, size: Int = 5) async throws -> SeasonHistoryDataDTO {
        let endpoint = SeasonHistoryEndpoint.userHistory(page: page, size: size)
        let response: SeasonHistoryAPIResponse = try await network.requestAsync(endpoint)
        return response.data
    }

    /// 사용자 주차별 구역 점수 조회
    /// - Parameter periodId: 주차 기간 ID (없으면 현재 기간)
    func fetchUserZoneScoresAsync(periodId: String? = nil) async throws -> UserZoneScoresDataDTO {
        let endpoint = SeasonHistoryEndpoint.userZoneScores(periodId: periodId)
        let response: UserZoneScoresAPIResponse = try await network.requestAsync(endpoint)
        return response.data
    }
}


