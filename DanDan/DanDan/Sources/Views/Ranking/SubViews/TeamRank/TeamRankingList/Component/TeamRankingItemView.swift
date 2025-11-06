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

    var body: some View {
        HStack {
            Text("\(teamRankings.rank)")
                .font(.PR.title2)
                .padding(.horizontal, 24)

            // TODO: 팀 이미지 추가
//            ProfileImageView(image: teamRankings.userImage, isMyRank: isMyRank)

            Text(teamRankings.teamName == "Blue" ? "A팀" :
                 teamRankings.teamName == "Yellow" ? "B팀" :
                 teamRankings.teamName)
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

#Preview {
    VStack(spacing: 0) {
        TeamRankingItemView(
            teamRankings: TeamRanking(
                id: UUID(),
                teamName: "Blue",
                teamColor: "#4A90E2",
                conqueredZones: 4,
                rank: 1
            ),
            isMyRank: false
        )

        TeamRankingItemView(
            teamRankings: TeamRanking(
                id: UUID(),
                teamName: "Yellow",
                teamColor: "#FFD700",
                conqueredZones: 3,
                rank: 2
            ),
            isMyRank: true
        )

        TeamRankingItemView(
            teamRankings: TeamRanking(
                id: UUID(),
                teamName: "Green",
                teamColor: "#00FF00",
                conqueredZones: 2,
                rank: 3
            ),
            isMyRank: false
        )
    }
    .background(Color.gray1)
}
