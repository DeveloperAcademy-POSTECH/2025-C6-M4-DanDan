//
//  WaitingView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import SwiftUI

// 11월 14일 16시에 TeamAssignmentView로 이동
struct WaitingView: View {
    var body: some View {
        ZStack {
            Image("bg_waiting")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .all)
                .offset(y: 100)
            
            TitleSectionView(title: "11월 14일 16시에 게임이 시작돼요", description: "몸을 풀며 기다려주세요!")
                .padding(.top, 50)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

//#Preview {
//    WaitingView()
//}
