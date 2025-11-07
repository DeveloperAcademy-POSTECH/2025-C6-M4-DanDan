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
    private let navigationManager = NavigationManager.shared
    
    var body: some View {
        TabView(selection: $selection){
            Tab("랭킹", systemImage: "trophy.fill", value: .ranking){
                RankingView()
            }
            Tab("지도", systemImage: "map.fill", value: .main){
                MapToggleView(
                    conquestStatuses: viewModel.conquestStatuses,
                    teams: viewModel.teams
                )
                .ignoresSafeArea()
            }
            Tab("마이페이지", systemImage: "person.fill", value: .my){
                MyPageView()
            }
        }
        .tint(.primaryGreen)
        .environmentObject(viewModel)
        .toolbar {
            if selection == .my {
                TitleIconToolBar(
                    title: "마이페이지",
                    trailingSystemImage: "gearshape.fill"
                ) {
                    navigationManager.navigate(to: .settings)
                }
            }
        }
    }
}
