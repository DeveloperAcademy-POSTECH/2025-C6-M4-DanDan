//
//  TeamPalette+ZoneColorResolver.swift
//  DanDan
//
//  Created by soyeonsoo on 11/4/25.
//

import UIKit

enum TeamPalette {
    static func uiColor(from name: String) -> UIColor {
        return UIColor(named: name) ?? .gray
    }
}

enum ZoneColorResolver {
    /// 특정 구역(zoneId)에 대해 점수가 가장 높은 팀의 상태를 반환
    static func leadingStatus(for zoneId: Int, in statuses: [ZoneConquestStatus]) -> ZoneConquestStatus? {
        // 같은 구역(zoneId)만 필터링
        let filtered = statuses.filter { $0.zoneId == zoneId && $0.teamScore != nil }
        
        // 점수가 높은 순으로 정렬해서 첫 번째 팀 반환
        return filtered.max(by: { ($0.teamScore ?? 0) < ($1.teamScore ?? 0) })
    }
    
    /// zoneId에 해당하는 팀 이름(leadingTeamName)에 매칭되는 색상 반환
    static func leadingColorOrDefault(
        for zoneId: Int,
        zoneStatuses: [ZoneStatus],
        defaultColor: UIColor = .primaryGreen
    ) -> UIColor {
        // zoneStatuses에서 해당 zoneId 찾기
        guard let status = zoneStatuses.first(where: { $0.zoneId == zoneId }) else {
            print("⚠️ Zone \(zoneId) → 데이터 없음")
            return defaultColor
        }

        // leadingTeamName이 nil이면 기본색
        guard let teamName = status.leadingTeamName else {
            return defaultColor
        }

//        // 👇 zoneStatuses 전체 데이터 확인용 디버그 로그
        print("📦 현재 zoneStatuses 데이터 (\(zoneStatuses.count)개):")
        for status in zoneStatuses {
            print("   - Zone \(status.zoneId): \(status.leadingTeamName)")
        }
        
        // 팀 이름에 따라 색 지정 (여기서는 asset catalog 기준)
        switch teamName {
        case "Blue":
            print("🎯 Zone \(zoneId) → TeamName(raw): \(teamName)")
            print("🎯 TeamName(lowercased): \(teamName.lowercased())")
            return .A
        case "Yellow":
            
            return .B
        default:
            return defaultColor
        }
    }
}

extension ZoneColorResolver {
    /// 특정 구역(zoneId)에 대해 점령 중인 팀의 색상을 반환, 승자가 없으면 기본색 반환
    static func leadingColorOrDefault(
        for zoneId: Int,
        in statuses: [ZoneConquestStatus],
        teams: [Team],
        defaultColor: UIColor = .primaryGreen
    ) -> UIColor {
        guard let winner = leadingStatus(for: zoneId, in: statuses),
              let winnerName = winner.teamName,
              let team = teams.first(where: { $0.teamName == winnerName })
        else {
            return defaultColor
        }
        return TeamPalette.uiColor(from: team.teamColor)
    }
}
