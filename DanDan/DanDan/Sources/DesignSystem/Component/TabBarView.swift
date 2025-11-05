//
//  TabBarView.swift
//  DanDan
//
//  Created by soyeonsoo on 10/30/25.
//

import SwiftUI

struct TabBarView: View {
    @State private var selection: AppTab = .main
    @StateObject private var viewModel = RankingViewModel()

    var body: some View {
        TabView(selection: $selection){
            Tab("랭킹", systemImage: "trophy.fill", value: .ranking){
                // TODO: 더미데이터 수정
                RankingView(viewModel: .dummy)
            }
            Tab("지도", systemImage: "map.fill", value: .main){
                MapToggleView(
                    conquestStatuses: viewModel.conquestStatuses,
                    teams: viewModel.teams
                )
                .ignoresSafeArea()
            }
            Tab("마이페이지", systemImage: "person.fill", value: .my){
                // TODO: 마이페이지 뷰 구현 후 주석 풀기
                // MyPageView()
            }
        }
        .tint(.primaryGreen)
        .environmentObject(viewModel)
    }
}
