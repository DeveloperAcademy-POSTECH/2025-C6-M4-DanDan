//
//  RankingCard.swift
//  DanDan
//
//  Created by Jay on 11/4/25.
//

import SwiftUI

struct RankingCard: View {
    private let userId: UUID
    private let myUserId: UUID
    private let image: Image
    private let name: String
    private let color: Color
    private let score: Int
    private let rank: Int

    init(
        userId: UUID,
        myUserId: UUID,
        name: String,
        score: Int,
        image: Image = Image("testImage"),
        color: Color = .gray3,
        rank: Int
    ) {
        self.userId = userId
        self.myUserId = myUserId
        self.name = name
        self.score = score
        self.image = image
        self.color = color
        self.rank = rank
    }

    private var rankBadgeImage: Image? {
        switch rank {
        case 1: return Image("rank_1")
        case 2: return Image("rank_2")
        case 3: return Image("rank_3")
        default: return nil
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                color

                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    .overlay(alignment: .topTrailing) {
                        if myUserId == userId {
                            MyRankBadgeView()
                                .offset(x: 3, y: -4)
                        }
                    }
                    .padding(.vertical, 10)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
            }

            VStack {
                Text(name)
                    .font(.PR.body2)
                    .foregroundStyle(.steelBlack)

                Text("\(score)점")
                    .font(.PR.body3)
                    .foregroundStyle(.gray2)
            }
            .padding(.vertical, 10)
        }
        .frame(width: 110, height: 135)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
        .overlay(alignment: .top) {
            if let badge = rankBadgeImage {
                badge
                    .resizable()
                    .frame(width: 39, height: 36)
                    .offset(y: -30)
            }

        }
    }
}

#Preview {
    VStack(spacing: 12) {
        RankingCard(
            userId: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            myUserId: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "황세연",
            score: 9,
            image: Image("testImage"),
            color: .subA50,
            rank: 1
        )

        RankingCard(
            userId: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            myUserId: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "김철수",
            score: 12,
            rank: 2
        )

        RankingCard(
            userId: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            myUserId: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "박지현",
            score: 7,
            rank: 3
        )
    }
}
