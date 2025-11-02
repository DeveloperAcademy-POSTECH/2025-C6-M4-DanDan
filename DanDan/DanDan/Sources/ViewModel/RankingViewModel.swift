//
//  RankingViewModel.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
class RankingViewModel: ObservableObject {
    @Published var conquestStatuses: [ZoneConquestStatus] = []
    @Published var rankedUsers: [UserStatus] = []
    
    private let navigationManager = NavigationManager.shared
    private let rankingManager = RankingManager.shared
    
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

// 뷰 전용 단순 데이터
struct RankingItemData: Identifiable {
    let id = UUID()
    let ranking: Int
    let userName: String
    let userImage: UIImage?
    let userConqueredZone: Int
    let userTeam: String
    let backgroundColor: Color
}

extension RankingViewModel {
    /// UserStatus + UserInfo → RankingItemData 변환 (기존 initializer 로직을 그대로 이전)
    func makeItemData(status: UserStatus, info: UserInfo) -> RankingItemData {
        let image: UIImage?
        if let firstData = info.userImage.first,
           let uiImage = UIImage(data: firstData) {
            image = uiImage
        } else {
            image = nil
        }
        
        let color: Color
        // TODO: 팀명 확정시 수정
        switch status.userTeam.lowercased() {
            case "blue": color = .subA20
            case "yellow": color = .subB20
            default: color = .gray5
        }
        
        return RankingItemData(
            ranking: status.rank,
            userName: info.userName,
            userImage: image,
            userConqueredZone: status.userDailyScore,
            userTeam: status.userTeam,
            backgroundColor: color
        )
    }
}
