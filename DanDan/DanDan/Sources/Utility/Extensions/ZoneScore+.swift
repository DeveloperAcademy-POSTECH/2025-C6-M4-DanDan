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
            let maxScore = zoneScores.map { $0.teamScore }.max() ?? 0
            let winners = zoneScores.filter { $0.teamScore == maxScore }

            let status: ZoneConquestStatus

            if winners.count == 1, let winner = winners.first {
                status = ZoneConquestStatus(
                    zoneId: zoneId,
                    teamId: winner.teamId,
                    teamName: winner.teamName,
                    teamScore: winner.teamScore
                )
            } else {
                status = ZoneConquestStatus(
                    zoneId: zoneId,
                    teamId: nil,
                    teamName: nil,
                    teamScore: nil)
            }
            
            results.append(status)
        }

        return results
    }
}
