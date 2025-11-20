//
//  TeamLabelView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/4/25.
//

import SwiftUI

enum TeamSide { case left, right }

/// 팀 라벨(이름·점수)을 한 줄로 표시.
/// - side: .left이면 "이름 점수", .right이면 "점수 이름" 순서
struct TeamLabel: View {
    let name: String
    let score: Int
    let side: TeamSide
    
    // TODO: UT 후 제거 - 팀 이름 맵핑
    private var mappedTeamName: String { name.teamDisplayName }
    
    var body: some View {
        switch side {
        case .left:
            HStack(spacing: 8) {
                Text(mappedTeamName)
                    .font(.PR.caption5)
                    .foregroundStyle(.black1)
                Text("\(score)")
                    .font(.PR.caption5)
                    .foregroundStyle(.black1)
            }
        case .right:
            HStack(spacing: 8) {
                Text("\(score)")
                    .font(.PR.caption5)
                    .foregroundStyle(.black1)
                Text(mappedTeamName)
                    .font(.PR.caption5)
                    .foregroundStyle(.black1)
            }
        }
    }
}
