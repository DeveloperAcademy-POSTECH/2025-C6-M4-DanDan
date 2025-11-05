//
//  RankingCardSectionv.swift
//  DanDan
//
//  Created by Jay on 11/5/25.
//

import SwiftUI

struct RankingCardSectionView: View {
    var body: some View {
        HStack(spacing: 12) {
            // TODO: 랭킹카드 로직 연결 필요
            RankingCard(
                name: "황세연",
                score: 9,
                image: Image("testImage"),
                color: .subB
            )

            RankingCard(
                name: "해피",
                score: 1
            )

            .padding(.bottom, 20)

            RankingCard(
                name: "황세연",
                score: 9,
                image: Image("testImage"),
                color: .subA
            )
        }
    }
}

#Preview {
    RankingCardSectionView()
}
