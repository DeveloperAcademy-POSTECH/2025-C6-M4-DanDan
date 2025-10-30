//
//  Main.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()

    var body: some View {

        Button {
            viewModel.tapRankingButton()
        } label: {
            Text("랭킹 페이지 이동")
        }

        if viewModel.shouldShowScoreButton {
            Button {
                viewModel.handleScoreButtonTapped(zoneId: 1)
            } label: {
                Text("1구역 점수 획득 버튼")
            }
        } else {
            Text("오늘은 이미 점수 획득")
        }
    }
}

#Preview {
    MainView()
}
