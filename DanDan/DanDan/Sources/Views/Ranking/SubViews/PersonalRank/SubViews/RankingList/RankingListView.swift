//
//  RankingListView.swift
//  DanDan
//
//  Created by Jay on 11/3/25.
//

import SwiftUI

struct RankingListView: View {
    @State private var isMyRankVisible: Bool = true
    
    let rankingItems: [RankingItemData]
    let myUserId: UUID
    let rankDiff: Int

    private var sortedItems: [RankingItemData] {
        rankingItems.sorted { $0.ranking < $1.ranking }
    }

    private var topThreeItems: [RankingItemData] {
        Array(sortedItems.prefix(3))
    }

    private var remainingItems: [RankingItemData] {
        Array(sortedItems.dropFirst(3))
    }
    
    private var myRankItem: RankingItemData? {
        rankingItems.first(where: { $0.id == myUserId })
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { outerGeo in
                ScrollView {
                    VStack(spacing: 0) {
                        if !topThreeItems.isEmpty {
                            RankingCardSectionView(
                                rankingItems: topThreeItems,
                                myUserId: myUserId
                            )
                            .padding(.vertical, 36)
                        }
                        
                        ForEach(Array(remainingItems.enumerated()), id: \.element.id) { index, item in
                            RankingItemView(
                                rank: item,
                                isMyRank: item.id == myUserId,
                                displayRank: index + 4,
                                rankDiff: rankDiff
                            )
                            .padding(.horizontal, 20)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onChange(of: geo.frame(in: .named("scrollArea")).minY) { _ in
                                                
                                            let frame = geo.frame(in: .named("scrollArea"))
                                            let top = frame.minY // 24
                                            let bottom = frame.maxY // 200
                                            
                                            // scrollView 높이를 기준으로 플로팅 판단
                                            let isVisible = bottom > 0 && top < outerGeo.size.height
                                            
                                            if item.id == myUserId {
                                                withAnimation {
                                                    self.isMyRankVisible = isVisible
                                                }
                                            }
                                        }
                                }
                            )
                        }
                    }
                }
                .coordinateSpace(name: "scrollArea")
            }
            if !isMyRankVisible, let myRankItem {
                MyRankFloatingCard(
                    rankItem: myRankItem,
                    rankDiff: rankDiff
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .transition(.move(edge: .bottom).combined(with: .blurReplace))
                .animation(.spring(), value: isMyRankVisible)
            }
        }
    }
}

//#Preview {
//    // 더미 유저 ID
//    let myId = UUID()
//    
//    // 더미 데이터 (3명 이상)
//    let sampleItems: [RankingViewModel.RankingItemData] = [
//        .init(
//            id: myId,
//            ranking: 6,
//            userName: "해피제이",
//            userImage: nil,
//            userWeekScore: 20,
//            userTeam: "Blue",
//            backgroundColor: .gray,
//            rankDiff: nil
//        ),
//        .init(
//            id: UUID(),
//            ranking: 1,
//            userName: "노터",
//            userImage: nil,
//            userWeekScore: 40,
//            userTeam: "Blue",
//            backgroundColor: .gray,
//            rankDiff: nil
//        ),
//        .init(
//            id: UUID(),
//            ranking: 2,
//            userName: "세나",
//            userImage: nil,
//            userWeekScore: 35,
//            userTeam: "Blue",
//            backgroundColor: .gray,
//            rankDiff: nil
//        ),
//        .init(
//            id: UUID(),
//            ranking: 3,
//            userName: "쁘",
//            userImage: nil,
//            userWeekScore: 30,
//            userTeam: "Blue",
//            backgroundColor: .gray,
//            rankDiff: nil
//        ),
//        .init(
//            id: UUID(),
//            ranking: 5,
//            userName: "브랜뉴",
//            userImage: nil,
//            userWeekScore: 10,
//            userTeam: "Blue",
//            backgroundColor: .gray,
//            rankDiff: nil
//        ),
//        .init(
//            id: UUID(),
//            ranking: 5,
//            userName: "브랜뉴",
//            userImage: nil,
//            userWeekScore: 10,
//            userTeam: "Blue",
//            backgroundColor: .gray,
//            rankDiff: nil
//        ),
//        .init(
//            id: UUID(),
//            ranking: 5,
//            userName: "브랜뉴",
//            userImage: nil,
//            userWeekScore: 10,
//            userTeam: "Blue",
//            backgroundColor: .gray,
//            rankDiff: nil
//        ),
//        .init(
//            id: UUID(),
//            ranking: 5,
//            userName: "브랜뉴",
//            userImage: nil,
//            userWeekScore: 10,
//            userTeam: "Blue",
//            backgroundColor: .gray,
//            rankDiff: nil
//        )
//    ]
//    
//    RankingListView(
//        rankingItems: sampleItems,
//        myUserId: myId,
//        myRankDiff: -1 // "1계단 하락" 같은 느낌
//    )
//}
