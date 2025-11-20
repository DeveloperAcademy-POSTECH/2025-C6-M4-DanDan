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
    private let userTeam: String
    private let score: Int
    private let rank: Int

    init(
        userId: UUID,
        myUserId: UUID,
        name: String,
        score: Int,
        image: Image = Image("default_avatar"),
        userTeam: String,
        rank: Int
    ) {
        self.userId = userId
        self.myUserId = myUserId
        self.name = name
        self.score = score
        self.image = image
        self.userTeam = userTeam
        self.rank = rank
        
        if userTeam.lowercased() == "blue" {
            self.color = Color("SubA50")
        } else if userTeam.lowercased() == "yellow" {
            self.color = Color("SubB")
        } else {
            self.color = .gray3
        }
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
                    .scaledToFill()  
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    .overlay(alignment: .topTrailing) {
                        if myUserId == userId {
                            MyRankBadgeView()
                                .offset(x: 3, y: -4)
                        }
                    }
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
            }
            .padding(.bottom, 10)

            // TODO: UT 후 수정
            VStack(spacing: 4) {
                Text(name)
                    .font(.PR.body2)
                    .foregroundStyle(.steelBlack)
                

                Text("\(score)점")
                    .font(.PR.body3)
                    .foregroundStyle(.gray2)
            }
            .padding(.bottom, 10)
            
            // UT용
//            VStack{
//                Text("대동중 X 제철중")
//                    .font(.PR.body4)
//                    .foregroundStyle(.gray3)
//                
//                HStack {
//                    Text(name)
//                        .font(.PR.body2)
//                        .foregroundStyle(.steelBlack)
//                    
//                    Text("\(score)점")
//                        .font(.PR.body3)
//                        .foregroundStyle(.gray2)
//                }
//                .padding(.vertical, 10)
//            }
        }
        .frame(width: 110, height: 140)
        .background(Color.steelWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.20), radius: 2, x: 0, y: 2)
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
    RankingCard(
        userId: UUID(),
        myUserId: UUID(),
        name: "김소원",
        score: 9,
        image: Image("default_avatar"),
        userTeam: "blue",   // 🔵 여기서 색상 매핑 테스트 가능
        rank: 1
    )
    .previewLayout(.sizeThatFits)
    .padding()
    .background(Color.gray.opacity(0.1))
}
