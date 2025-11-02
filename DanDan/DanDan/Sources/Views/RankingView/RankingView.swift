//
//  RankingView.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

struct RankingView: View {
    @StateObject private var viewModel = RankingViewModel()

    var body: some View {
        VStack {
            TeamRankView()
        }
        .padding()
    }
}

#Preview {
    RankingView()
}
