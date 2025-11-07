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

    private let network: NetworkServiceProtocol

    init(network: NetworkServiceProtocol = NetworkService()) {
        self.network = network
    }

    /// 유저 시즌 히스토리 조회 (최신순, 페이지네이션)
    func fetchUserHistory(page: Int = 0, size: Int = 5) -> AnyPublisher<SeasonHistoryDataDTO, NetworkError> {
        let endpoint = SeasonHistoryEndpoint.userHistory(page: page, size: size)
        return network
            .request(endpoint)
            .map { (response: SeasonHistoryAPIResponse) in response.data }
            .eraseToAnyPublisher()
    }
}


