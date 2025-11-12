//
//  RankingItemView.swift
//  DanDan
//
//  Created by soyeonsoo on 10/31/25.
//

import SwiftUI

struct TeamRankingItemView: View {
    let teamRankings: TeamRanking
    let isMyRank: Bool
    
    // TODO: UT 후 제거 - 팀 이름 맵핑
    private var mappedTeamName: String {
        switch teamRankings.teamName {
        case "Blue": return "포항이동고"
        case "Yellow": return "대동중 X 세명고"
        default: return teamRankings.teamName
        }
    }
    
    var body: some View {
        HStack {
            Text("\(teamRankings.rank)")
                .font(.PR.title2)
                .padding(.horizontal, 24)

            // TODO: 팀 이미지 추가
//            ProfileImageView(image: teamRankings.userImage, isMyRank: isMyRank)

            Text("\(mappedTeamName)")
                .font(.PR.body2)
                .lineLimit(1)
                .padding(.leading, 12)

            Spacer()

            Text("\(teamRankings.conqueredZones)")
                .padding(.trailing, 24)
                .font(.PR.caption1)
                .foregroundStyle(.gray2)
        }
        .padding(.vertical, 37)
        .background(Color.setBackgroundColor(for: teamRankings.teamName))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(teamRankings.teamName ==  "Blue" ? Color.A : Color.B, lineWidth: isMyRank ? 3 : 0)
        )
        .padding(.bottom, 8)
    }
}
