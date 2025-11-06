//
//  RankingCard.swift
//  DanDan
//
//  Created by Jay on 11/4/25.
//

import SwiftUI

struct RankingCard: View {
    private let image: Image
    private let name: String
    private let color: Color
    private let score: Int
    
    init(
        name: String,
        score: Int,
        image: Image = Image("testImage"),
        color: Color = .gray3
    ) {
        self.name = name
        self.score = score
        self.image = image
        self.color = color
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
    }
}

#Preview {
    VStack(spacing: 12) {
        RankingCard(
            name: "황세연",
            score: 9,
            image: Image("testImage"),
            color: .subA50
        )

        RankingCard(
            name: "김철수",
            score: 12
        )
    }
}
