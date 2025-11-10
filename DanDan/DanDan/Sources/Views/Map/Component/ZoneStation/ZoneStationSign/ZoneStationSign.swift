//
//  ZoneStationSignView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/2/25.
//

import SwiftUI

/// 뷰에 필요한 최소 점수 데이터(표시 전용)
struct ZoneScorePair {
    let leftTeamName: String?
    let leftScore: Int?
    let rightTeamName: String?
    let rightScore: Int?
}

struct ZoneStationSign: View {
    @ObservedObject var viewModel: MapScreenViewModel
    let zone: Zone
    let statusesForZone: [ZoneConquestStatus] // 같은 zoneId를 가진 두 팀의 상태들 (순서는 무관)
    
    // 캐시에서 읽은 서버 점수 → ZoneScorePair로 변환
    private var scorePairFromServer: ZoneScorePair? {
        guard let scores = viewModel.zoneTeamScores[zone.zoneId], scores.count >= 1 else {
            return nil
        }
        // 최대 2팀까지만 UI에 표기
        let left  = scores.indices.contains(0) ? scores[0] : nil
        let right = scores.indices.contains(1) ? scores[1] : nil
        return ZoneScorePair(
            leftTeamName: left?.teamName,
            leftScore: left?.totalScore,
            rightTeamName: right?.teamName,
            rightScore: right?.totalScore
        )
    }
    
    // 기존 폴백(로컬 상태 기반)
    private var scorePairFromFallback: ZoneScorePair {
        let filtered = statusesForZone.filter { $0.zoneId == zone.zoneId }
        let left  = filtered.indices.contains(0) ? filtered[0] : nil
        let right = filtered.indices.contains(1) ? filtered[1] : nil
        
        return ZoneScorePair(
            leftTeamName: left?.teamName,
            leftScore: left?.teamScore,
            rightTeamName: right?.teamName,
            rightScore: right?.teamScore
        )
    }
    
    // 최종 표시값: 서버 > 폴백
    private var scorePair: ZoneScorePair {
        scorePairFromServer ?? scorePairFromFallback
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ZoneStationSignHeader(zoneId: zone.zoneId, zoneName: zone.zoneName) // 상단: 구역 번호 + 이름
            ZoneStationSignScore(scorePair: scorePair) // 하단: 팀명 + 팀 점수
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(Capsule().stroke(.black, lineWidth: 4))
        )
        .task {
            await viewModel.loadZoneTeamScores(for: zone.zoneId)
        }
    }
}
