//
//  RankingItemView.swift
//  DanDan
//
//  Created by soyeonsoo on 10/31/25.
//

import SwiftUI

struct RankingItemView: View {
    var rank: RankingViewModel.RankingItemData
    var isMyRank: Bool

    init(rank: RankingViewModel.RankingItemData, isMyRank: Bool = false) {
        self.rank = rank
        self.isMyRank = isMyRank
    }

    // TODO: 폰트셋 추가 후 수정
    var body: some View {
        HStack {
            Text("\(rank.ranking)")
                .font(.system(size: 18, weight: .bold))
                .frame(width: 36)
                .padding(.horizontal, 12)

            ProfileImageView(image: rank.userImage)

            Text(rank.userName)
                .font(.system(size: 16))
                .lineLimit(1)
                .padding(.leading, 12)

            Spacer()

            Text("\(rank.userWeekScore)")
                .padding(.trailing, 24)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.gray)
        }
        .padding(.vertical, 16)
        .background(rank.backgroundColor)
        .cornerRadius(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
            // TODO: 컬러 변경
                .strokeBorder(Color("PointGreen01"), lineWidth: isMyRank ? 3 : 0)
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
        )
    }
    .padding()
}
