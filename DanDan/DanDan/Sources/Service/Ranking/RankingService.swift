//
//  RankingService.swift
//  DanDan
//
//  Created by Jay on 11/5/25.
//

import Combine
import Foundation

class RankingService {
    static let shared = RankingService()
    private let networkService: NetworkServiceProtocol

    private init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    /// 전체 랭킹 리스트 요청
    func fetchOverallRanking() -> AnyPublisher<[RankingResponseDTO], NetworkError> {
            networkService.request(RankingEndPoint.rankingList)
                .map { (response: RankingAPIResponse) in
                    response.data.rankings // 🔥 DTO 배열만 꺼내기
                }
                .eraseToAnyPublisher()
        }
}
