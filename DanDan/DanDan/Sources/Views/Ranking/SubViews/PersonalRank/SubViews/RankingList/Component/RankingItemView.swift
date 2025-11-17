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
    let myRankDiff: Int
    
    // TODO: UT 후 수정
    private var mappedTeamName: String {
        switch rank.userTeam {
        case "Blue": return "세명고"
        case "Yellow": return "대동중 X 이동고"
        default: return rank.userTeam
        }
    }

    var body: some View {
        HStack {
            Text("\(displayRank)")
                .font(.PR.title2)
                .padding(.horizontal, 24)
                .foregroundStyle(.darkGreen)
                .overlay() {
                    if isMyRank {
                        RankingChangeIndicatorView(rankDiff: myRankDiff)
                            .offset(y: 21)
                    }
                }

            ProfileImageView(image: rank.userImage, isMyRank: isMyRank)

            Text(rank.userName)
                .font(isMyRank ? .PR.title2 : .PR.body3)
                .foregroundStyle(.steelBlack)
                .lineLimit(1)
                .padding(.leading, 12)

            Spacer()
            
            // TODO: UT 후 수정
            Text(mappedTeamName)
                .padding(.trailing, 5)
                .font(.PR.body4)
                .foregroundStyle(.gray3)

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
