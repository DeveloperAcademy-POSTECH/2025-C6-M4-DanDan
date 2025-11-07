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
    let displayRank: Int

    var body: some View {
        HStack {
            Text("\(displayRank)")
                .font(.PR.title2)
                .padding(.horizontal, 24)
                .overlay() {
                    if isMyRank {
                        // TODO: 변동 순위 rankDiff에 연동
                        RankingChangeIndicatorView(rankDiff: 4)
                            .offset(y: 21)
                    }
                }

            ProfileImageView(image: rank.userImage, isMyRank: isMyRank)

            Text(rank.userName)
                .font(isMyRank ? .PR.title2 : .PR.body3)
                .lineLimit(1)
                .padding(.leading, 12)

            Spacer()

            Text("\(rank.userWeekScore)")
                .padding(.trailing, 24)
                .font(.PR.caption1)
                .foregroundStyle(.gray2)
        }
        .padding(.vertical, isMyRank ? 20 : 16)
        .background(isMyRank ? Color.lightGreen : rank.backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.primaryGreen, lineWidth: isMyRank ? 3 : 0)
        )
        .padding(.bottom, 8)
    }
}
