//
//  PersonalRankView.swift
//  DanDan
//
//  Created by Jay on 11/2/25.
//

import SwiftUI

struct PersonalRankView: View {
    let rankingItems: [RankingViewModel.RankingItemData]
    let myUserId: UUID
    let rankingFilter: (
            [RankingViewModel.RankingItemData],
            String,
            UUID
    ) -> [RankingViewModel.RankingItemData]

    @State private var selectedFilter: String = "전체"
    
    private var filteredItems: [RankingViewModel.RankingItemData] {
            rankingFilter(rankingItems, selectedFilter, myUserId)
        }
    
    var body: some View {
        VStack(spacing: 0) {
            InstructionSectionView(selectedFilter: $selectedFilter)
                .padding(.top, 52)

            RankingListView(
                rankingItems: filteredItems,
                myUserId: myUserId
            )
        }
        .padding(.horizontal, 20)
    }
}

//#Preview {
//    PersonalRankView(
//        rankingItems: [
//            .init(
//                id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
//                ranking: 1,
//                userName: "소연수",
//                userImage: nil,
//                userWeekScore: 12,
//                userTeam: "blue",
//                backgroundColor: .blue.opacity(0.1)
//            ),
//            .init(
//                id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
//                ranking: 2,
//                userName: "김소원",
//                userImage: nil,
//                userWeekScore: 9,
//                userTeam: "blue",
//                backgroundColor: .blue.opacity(0.1)
//            ),
//            .init(
//                id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
//                ranking: 3,
//                userName: "허찬욱",
//                userImage: nil,
//                userWeekScore: 7,
//                userTeam: "yellow",
//                backgroundColor: .yellow.opacity(0.1)
//            ),
//        ],
//        myUserId: UUID(uuidString: "22222222-2222-2222-2222-222222222222")! 
//    )
//}
