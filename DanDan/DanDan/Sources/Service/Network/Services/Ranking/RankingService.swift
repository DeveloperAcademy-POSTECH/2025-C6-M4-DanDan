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
    
    // MARK: - 개인 랭킹

    /// 전체 유저 랭킹 리스트 요청
    func fetchOverallRanking() -> AnyPublisher<
        [RankingResponseDTO], NetworkError
    > {
        networkService.request(RankingEndPoint.rankingList)
            .map { (response: RankingAPIResponse) in
                response.data.rankings  
            }
            .eraseToAnyPublisher()
    }
    
    /// 현재 유저 랭킹 요청
    func requestMyRanking() async throws -> MyRankingData {
        guard let url = URL(string: "https://www.singyupark.cloud:8443/api/v1/conquest/rankings/my-rank") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = try? TokenManager().getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decodedResponse = try JSONDecoder().decode(MyRankingResponseDTO.self, from: data)
        
        return decodedResponse.data
    }
    
    /// 현재 유저 팀의 개인 랭킹
    func requestMyTeamRanking() async throws -> [MyTeamRankingData] {
        guard let url = URL(string: "https://www.singyupark.cloud:8443/api/v1/conquest/rankings?type=team") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = try? TokenManager().getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw URLError(.userAuthenticationRequired)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decodedResponse = try JSONDecoder().decode(MyTeamRankingResponseDTO.self, from: data)

        return decodedResponse.data
    }
    
    // MARK: - 팀 랭킹
    
    func fetchTeamRankings() async throws -> [TeamRanking] {
        guard let url = URL(string: "https://www.singyupark.cloud:8443/api/v1/conquest/rankings/teams") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decodedResponse = try JSONDecoder().decode(TeamRankingResponseDTO.self, from: data)
        return decodedResponse.data.rankings
    }
}
