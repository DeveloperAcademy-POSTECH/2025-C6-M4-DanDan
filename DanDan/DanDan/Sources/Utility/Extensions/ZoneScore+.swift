//
//  ZoneScore.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

extension ZoneScore {
    static func evaluatePerZone(scores: [ZoneScore]) -> [ZoneConquestStatus] {
        let grouped = Dictionary(grouping: scores, by: { $0.zoneId })

        var results: [ZoneConquestStatus] = []

        for (zoneId, zoneScores) in grouped {
            let maxScore = zoneScores.map { $0.score }.max() ?? 0
            let winners = zoneScores.filter { $0.score == maxScore }

            let status: ZoneConquestStatus

            if winners.count == 1, let winner = winners.first {
                status = ZoneConquestStatus(
                    zoneId: zoneId,
                    teamId: winner.teamId,
                    teamName: winner.teamName,
                    isConquered: false
                )
            } else {
                status = ZoneConquestStatus(
                    zoneId: zoneId,
                    teamId: nil,
                    teamName: nil,
                    isConquered: true
                )
            }
            
            results.append(status)
        }

        return results
    }
}
