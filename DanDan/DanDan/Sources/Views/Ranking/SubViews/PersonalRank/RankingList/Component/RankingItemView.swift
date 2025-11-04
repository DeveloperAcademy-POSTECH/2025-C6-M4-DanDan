//
//  RankingItemView.swift
//  DanDan
//
//  Created by soyeonsoo on 10/31/25.
//

import SwiftUI

struct RankingItemView: View {
    let rank: RankingViewModel.RankingItemData
    let isMyRank: Bool

    // TODO: 폰트셋 추가 후 수정
    var body: some View {
        HStack {
            Text("\(rank.ranking)")
                .font(.PR.title2)
                .padding(.horizontal, 24)

            ProfileImageView(image: rank.userImage)

            Text(rank.userName)
                .font(.PR.body3)
                .lineLimit(1)
                .padding(.leading, 12)

            Spacer()

            Text("\(rank.userWeekScore)")
                .padding(.trailing, 24)
                .font(.PR.caption1)
                .foregroundStyle(.gray2)
        }
        .background(isMyRank ? Color.lightGreen : rank.backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
            // TODO: 컬러 변경
                .strokeBorder(Color.primaryGreen, lineWidth: isMyRank ? 3 : 0)
        )
    }
}

#Preview {
    VStack(spacing: 8) {
        RankingItemView(
            rank: .init(
                ranking: 1,
                userName: "소연수",
                userImage: nil,
                userWeekScore: 12,
                userTeam: "blue",
                backgroundColor: .blue.opacity(0.1)
            )
            , isMyRank: false
        )
        RankingItemView(
            rank: .init(
                ranking: 2,
                userName: "김소원",
                userImage: nil,
                userWeekScore: 9,
                userTeam: "blue",
                backgroundColor: .blue.opacity(0.1)
            )
            , isMyRank: true
        )
        RankingItemView(
            rank: .init(
                ranking: 3,
                userName: "허찬욱",
                userImage: nil,
                userWeekScore: 7,
                userTeam: "yellow",
                backgroundColor: .yellow.opacity(0.1)
            )
            , isMyRank: false
        )
    }
    .padding()
}
