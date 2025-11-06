//
//  RankingResponseDTO.swift
//  DanDan
//
//  Created by Jay on 11/5/25.
//

import SwiftUI

/// 서버에서 내려주는 랭킹 응답 모델
struct RankingResponseDTO: Decodable {
    let id: UUID
    let ranking: Int
    let userName: String
    let userImage: String?
    let userWeekScore: Int
    let userTeam: String
    let backgroundColor: String?
}

struct RankingAPIResponse: Decodable {
    let success: Bool
    let code: String
    let message: String
    let data: RankingDataResponse
}

/// 서버 DTO → 내부 뷰 모델 변환용 이니셜라이저
extension RankingViewModel.RankingItemData {
    init(from dto: RankingResponseDTO) {
        self.id = dto.id
        self.ranking = dto.ranking
        self.userName = dto.userName
        self.userImage = nil // 나중에 UIImage 로드 (AsyncImage로 대체 가능)
        self.userWeekScore = dto.userWeekScore
        self.userTeam = dto.userTeam
        self.backgroundColor = Color(hex: dto.backgroundColor ?? "#EAEAEA")
    }
}


