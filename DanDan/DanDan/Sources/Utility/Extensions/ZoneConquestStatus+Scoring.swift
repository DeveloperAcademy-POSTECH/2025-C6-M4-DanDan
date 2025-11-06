//
//  ZoneConquestStatus+Scoring.swift
//  DanDan
//
//  Created by soyeonsoo on 11/4/25.
//

// ZoneConquestStatus + 팀 점수 집계 헬퍼
/// ZoneConquestStatus 배열을 받아 각 구역의 승리 팀을 뽑아 팀별 점령 구역 수를 딕셔너리로 반환
extension Array where Element == ZoneConquestStatus {
    /// zoneId별 최고 득점 팀만 1점 획득(동점/스코어 nil은 무득점)
    func capturedZonesPerTeam() -> [String: Int] {
        let grouped = Dictionary(grouping: self, by: { $0.zoneId })

        // 승리 팀만 카운트
        var result: [String: Int] = [:]

        for (_, statuses) in grouped {
            // 점수 있는 구역 중에서 최고 득점 팀의 이름과 점수
            let withScore = statuses.compactMap { s -> (name: String, score: Int)? in
                guard let name = s.teamName, let sc = s.teamScore else { return nil }
                return (name, sc)
            }
            guard let winner = withScore.max(by: { $0.score < $1.score }) else { continue }

            // 동점이면 그 구역은 어느 팀도 점수 획득 X
            let topScore = winner.score
            let topCount = withScore.filter { $0.score == topScore }.count
            if topCount > 1 { continue }

            result[winner.name, default: 0] += 1
        }

        return result
    }
}

extension Array where Element == ZoneConquestStatus {
    /// teams[0]을 left, teams[1]을 right로 간주해 점령 구역 수를 ZoneScorePair로 변환
    func scorePair(for teams: [Team]) -> ZoneScorePair {
        let counts = self.capturedZonesPerTeam()

        let leftName  = teams.indices.contains(0) ? teams[0].teamName : nil
        let rightName = teams.indices.contains(1) ? teams[1].teamName : nil

        let leftScore  = leftName.flatMap { counts[$0] } ?? 0
        let rightScore = rightName.flatMap { counts[$0] } ?? 0

        return ZoneScorePair(
            leftTeamName: leftName,
            leftScore: leftScore,
            rightTeamName: rightName,
            rightScore: rightScore
        )
    }
}
