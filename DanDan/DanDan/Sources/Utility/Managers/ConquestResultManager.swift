//
//  ConquestResultManager.swift
//  DanDan
//
//  Created by Jay on 10/30/25.
//

import Foundation

/// 전체 구간의 점령 상태를 기반으로 팀별 점령 결과를 종합하는 매니저
class ConquestResultManager {
    
    /// 팀별로 점령한 구역 수를 계산합니다
    /// - Parameter zones: 현재 모든 구간의 점령 상태 배열
    /// - Returns: [팀 ID: 점령한 구역 수]
    func calculateTeamScores(from zones: [ZoneConquestStatus]) -> [Int: Int] {
        var teamZoneCounts: [Int: Int] = [:]
        
        for zone in zones {
            if let teamId = zone.teamId {
                teamZoneCounts[teamId, default: 0] += 1
            }
        }
        
        return teamZoneCounts
    }
}
