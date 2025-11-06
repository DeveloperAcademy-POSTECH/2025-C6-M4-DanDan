//
//  RankingResponse.swift
//  DanDan
//
//  Created by Jay on 11/5/25.
//

import Foundation

struct RankingDataResponse: Decodable {
    let periodId: UUID
    let rankings: [RankingResponseDTO]
}
