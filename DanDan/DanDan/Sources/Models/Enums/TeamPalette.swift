//
//  TeamPalette.swift
//  DanDan
//
//  Created by soyeonsoo on 11/3/25.
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
