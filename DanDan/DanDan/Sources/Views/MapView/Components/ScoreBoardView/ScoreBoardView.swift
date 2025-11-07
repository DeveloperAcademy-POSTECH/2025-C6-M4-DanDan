//
//  ScoreBoardView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/4/25.
//

import SwiftUI

struct ScoreBoardView: View {
    let leftTeamName: String
    let rightTeamName: String
    let leftTeamScore: Int
    let rightTeamScore: Int
    
    private var total: CGFloat {
        max(1, CGFloat(leftTeamScore + rightTeamScore))
    }
    private var leftRatio: CGFloat { CGFloat(leftTeamScore) / total }
    private var rightRatio: CGFloat { CGFloat(rightTeamScore) / total }
    
    var body: some View {
        ZStack {
            // 유리 컨테이너
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 14, x: 0, y: 8)
            
            // 안쪽 진행 바 & 라벨
            GeometryReader { geo in
                let inset: CGFloat = 8
                let barHeight: CGFloat = 28
                let barWidth = geo.size.width - inset * 2
                
                // 진행 바
                if leftTeamScore == 0 && rightTeamScore > 0 {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 8, bottomLeadingRadius: 8,
                        bottomTrailingRadius: 8, topTrailingRadius: 8,
                        style: .continuous
                    )
                    .fill(Color.B)
                    .frame(width: barWidth * rightRatio, height: barHeight)
                    .position(x: geo.size.width/2, y: geo.size.height/2)
                } else if rightTeamScore == 0 && leftTeamScore > 0 {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 8, bottomLeadingRadius: 8,
                        bottomTrailingRadius: 8, topTrailingRadius: 8,
                        style: .continuous
                    )
                    .fill(Color.A)
                    .frame(width: barWidth * leftRatio, height: barHeight)
                    .position(x: geo.size.width/2, y: geo.size.height/2)
                } else {
                    HStack(spacing: 2) {
                        UnevenRoundedRectangle(
                            topLeadingRadius: 8, bottomLeadingRadius: 8,
                            bottomTrailingRadius: 0, topTrailingRadius: 0,
                            style: .continuous
                        )
                        .fill(Color.A)
                        .frame(width: barWidth * leftRatio, height: barHeight)
                        
                        UnevenRoundedRectangle(
                            topLeadingRadius: 0, bottomLeadingRadius: 0,
                            bottomTrailingRadius: 8, topTrailingRadius: 8,
                            style: .continuous
                        )
                        .fill(Color.B)
                        .frame(width: barWidth * rightRatio, height: barHeight)
                    }
                    .position(x: geo.size.width/2, y: geo.size.height/2)
                }
                
                // 라벨
                // 0점인 팀은 진행 바, 라벨 모두 사라짐
                HStack {
                    if leftTeamScore > 0 || (leftTeamScore == 0 && rightTeamScore == 0) {
                        TeamLabel(name: leftTeamName,
                                  score: leftTeamScore,
                                  side: .left)
                        .padding(.leading, inset)
                    }
                    
                    Spacer()
                    
                    if rightTeamScore > 0 || (leftTeamScore == 0 && rightTeamScore == 0) {
                        TeamLabel(name: rightTeamName,
                                  score: rightTeamScore,
                                  side: .right)
                        .padding(.trailing, inset)
                    }
                }
                .frame(width: barWidth, height: barHeight)
                .position(x: geo.size.width/2, y: geo.size.height/2)
            }
            .padding(4)
        }
        .frame(width: 230, height: 44)
    }
}

//#Preview {
//    // 더미 팀 데이터
//    let teams = [
//        Team(id: UUID(), teamName: "Blue", teamColor: "A"),
//        Team(id: UUID(), teamName: "Yellow", teamColor: "B")
//    ]
//
//    // 더미 점령 상태 데이터
//    let dummyStatuses = [
//        ZoneConquestStatus(zoneId: 1, teamId: 1, teamName: "Blue", teamScore: 12),
//        ZoneConquestStatus(zoneId: 1, teamId: 2, teamName: "Yellow", teamScore: 19),
//        ZoneConquestStatus(zoneId: 2, teamId: 1, teamName: "Blue", teamScore: 34),
//        ZoneConquestStatus(zoneId: 2, teamId: 2, teamName: "Yellow", teamScore: 32)
//    ]
//
//    VStack(spacing: 20) {
//        ScoreBoardView(statuses: dummyStatuses, teams: teams)
//    }
//    .padding()
//    .background(
//        LinearGradient(colors: [.subA50, .subB20], startPoint: .top, endPoint: .bottom)
//            .ignoresSafeArea()
//    )
//}
