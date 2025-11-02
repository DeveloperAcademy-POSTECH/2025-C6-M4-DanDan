//
//  ZoneStationSignView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/2/25.
//

import SwiftUI

/// 뷰에 필요한 최소 점수 데이터(표시 전용)
private struct ZoneScorePair {
    let leftTeamName: String?
    let leftScore: Int?
    let rightTeamName: String?
    let rightScore: Int?
}

struct ZoneStationSignView: View {
    let zone: Zone
    /// 같은 zoneId를 가진 두 팀의 상태들 (순서는 무관)
    let statusesForZone: [ZoneConquestStatus]
    
    // 표시용 파싱 로직
    private var scorePair: ZoneScorePair {
        // zoneId 일치하는 것만 필터
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
    
    var body: some View {
        VStack(spacing: 6) {
            // 상단: 구역 번호 + 이름
            HStack(spacing: 8) {
                Text("\(zone.zoneId)")
                    .font(.PR.body2)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(.white))
                    .overlay(Circle().stroke(.black, lineWidth: 2))
                
                Text(zone.zoneName)
                    .font(.PR.body2)
                    .foregroundStyle(.black)
            }
            
            // 하단: 팀 점수 "A : B"
            if let l = scorePair.leftScore, let r = scorePair.rightScore {
                Text("\(l) : \(r)")
                    .font(.PR.body2)
                    .foregroundStyle(.gray)
            } else {
                Text("— : —")
                    .font(.PR.body2)
                    .foregroundStyle(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(Capsule().stroke(.black, lineWidth: 4))
        )
        .frame(width: 200)
    }
}

#Preview {
    let dummyZone = Zone(
        zoneId: 10,
        zoneName: "추억의길 1구역",
        coordinates: [
            .init(latitude: 36.029071, longitude: 129.355408),
            .init(latitude: 36.030591, longitude: 129.356849),
            .init(latitude: 36.033562, longitude: 129.358396),
            .init(latitude: 36.036393, longitude: 129.359417)
        ],
        zoneColor: .white
    )
    
    let teamBlue  = ZoneConquestStatus(zoneId: 10, teamId: 1, teamName: "Blue",  teamScore: 73)
    let teamYellow = ZoneConquestStatus(zoneId: 10, teamId: 2, teamName: "Yellow", teamScore: 23)
    
    return ZoneStationSignView(zone: dummyZone, statusesForZone: [teamBlue, teamYellow])
        .padding()
}
