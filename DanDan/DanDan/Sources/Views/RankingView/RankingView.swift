//
//  RankingView.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

struct RankingView: View {
    @StateObject var viewModel = RankingViewModel()

    var body: some View {

            Button {
                viewModel.tapMainButton()
            } label: {
                Text("홈")
            }
        }
        .padding()
    }
}

#Preview {
    RankingView()
}
