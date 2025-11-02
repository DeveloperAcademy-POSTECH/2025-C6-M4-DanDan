//
//  RankingView.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

struct RankingView: View {
    @StateObject private var viewModel = RankingViewModel()

    @State private var isRightSelected: Bool = false
    
    // TODO: 더미데이터 수정
    init(viewModel: RankingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            SegmentedControl(
                leftTitle: "팀",
                rightTitle: "개인",
                isRightSelected: $isRightSelected
            )

            if isRightSelected {
                Spacer()
                
                // TODO: 개인 랭킹 뷰
                Text("개인 랭킹 뷰 (다음 이슈 때 구현)")
                PersonalRankView(
                    rankingItems: viewModel.getRankingItemDataList()
                )
            } else {
                TeamRankView()
            }
        }
        .padding(.top, 45)

        Spacer()
    }
}

#Preview {
    RankingView(viewModel: .dummy)
}
