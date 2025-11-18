//
//  ff.swift
//  DanDan
//
//  Created by Jay on 11/10/25.
//

import Foundation

class CycleService {
    static let shared = CycleService()
    private init() {}

    /// 최종 점령전 결과를 요청합니다.
    func fetchLatestCompletedResults() async throws -> WinningResultData {
        guard let url = URL(string: "https://www.singyupark.cloud:8443/api/v1/conquest/periods/latest-completed/results") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(WinningResultResponse.self, from: data)
        
        return decoded.data
    }
    
    /// 현재 기간 정보를 요청합니다.
    func requestCurrentPeriod() async throws -> CurrentConquestPeriod {
        guard let url = URL(string: "https://www.singyupark.cloud:8443/api/v1/conquest/current-period") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(ConquestPeriodResponseDTO.self, from: data)
        
        return decoded.data
    }
}
