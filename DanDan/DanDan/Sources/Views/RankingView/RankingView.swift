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
                
                Spacer()
            } else {
                TeamRankView()
            }
        }
        .padding(.top, 45)
        
        Spacer()
    }
}

#Preview {
    RankingView()
}
