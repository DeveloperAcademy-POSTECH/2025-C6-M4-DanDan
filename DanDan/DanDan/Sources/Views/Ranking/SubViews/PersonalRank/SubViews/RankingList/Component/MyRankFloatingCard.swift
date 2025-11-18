//
//  MyRankFloatingCard.swift
//  DanDan
//
//  Created by Jay on 11/18/25.
//

import SwiftUI

struct MyRankFloatingCard: View {
    let rankItem: RankingItemData
    let rankDiff: Int

    var body: some View {
        HStack {
            Text("\(rankItem.ranking)")
                .font(.PR.title2)
                .padding(.horizontal, 24)
                .foregroundStyle(.darkGreen)
                .overlay() {
                    RankingChangeIndicatorView(rankDiff: rankDiff)
                        .offset(y: 21)
                }

            ProfileImageView(image: rankItem.userImage, isMyRank: true)

            Text(rankItem.userName)
                .font(.PR.title2)
                .foregroundStyle(.steelBlack)
                .lineLimit(1)
                .padding(.leading, 12)

            Spacer()

            Text("\(rankItem.userWeekScore)")
                .padding(.trailing, 24)
                .font(.PR.caption1)
                .foregroundStyle(.gray2)
        }
        /// 레이아웃을 맞추기 위하여 패딩에 +1.5씩 더 줌 - strokeBorder가 영역 내부로 그려지기 때문
        .padding(.vertical, 21.5)
        .background(Color.lightGreen)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.primaryGreen, lineWidth: 3)
        )
    }
}
