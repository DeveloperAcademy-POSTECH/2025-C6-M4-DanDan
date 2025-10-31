//
//  TabBarView.swift
//  DanDan
//
//  Created by soyeonsoo on 10/30/25.
//

import SwiftUI

struct TabBarView: View {
    @State private var selection: AppTab = .main
    
    var body: some View {
        TabView(selection: $selection){
            Tab("랭킹", systemImage: "trophy.fill", value: .ranking){
                 RankingView()
            }
            Tab("지도", systemImage: "map.fill", value: .main){
                MapView()
                    .ignoresSafeArea()
            }
            Tab("마이페이지", systemImage: "person.fill", value: .my){
                // TODO: 마이페이지 뷰 구현 후 주석 풀기
                // MyPageView()
            }
        }
        // TODO: 컬러셋 세팅 후 수정 필요
        .tint(.teal) // 임의로 넣어둔 색
    }
}
