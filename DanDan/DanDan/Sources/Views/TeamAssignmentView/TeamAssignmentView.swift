//
//  TeamAssignmentView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import SwiftUI

struct TeamAssignmentView: View {
    private let navigationManager = NavigationManager.shared
    
    var userStatus: UserStatus = UserStatus()
    
    var body: some View {
        ZStack {
            Image("bg_team_assignment")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .all)
                .offset(y: 100)
            
            // 팀별 열차 이미지 분기
            if userStatus.userTeam.lowercased() == "blue" {
                Image("train_blue")
                    .resizable()
                    .scaledToFit()
                    .offset(x: 20, y: 86)
            } else if userStatus.userTeam.lowercased() == "yellow" {
                Image("train_yellow")
                    .resizable()
                    .scaledToFit()
                    .offset(x: 20, y: 86)
            }
            
            VStack {
                if userStatus.userTeam.lowercased() == "blue" {
                    TitleSectionView(title: "당신은 파랑팀입니다!", description: "탭해서 게임 시작하기")
                        .padding(.top, 50)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                } else if userStatus.userTeam.lowercased() == "yellow" {
                    TitleSectionView(title: "당신은 노랑팀입니다!", description: "탭해서 게임 시작하기")
                        .padding(.top, 50)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
        }
        .contentShape(Rectangle()) // ZStack 전체 터치 영역 활성화
        .onTapGesture {
            navigationManager.navigate(to: .main)
        }
    }
}

//#Preview("Team Assignment") {
//    TeamAssignmentView(userStatus: {
//        var status = UserStatus()
//        status.userTeam = "yellow"
//        return status
//    }())
//    .frame(height: 350)
//}
