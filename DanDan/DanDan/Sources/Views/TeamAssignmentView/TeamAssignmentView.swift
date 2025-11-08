//
//  TeamAssignmentView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import SwiftUI

struct TeamAssignmentView: View {
    private let navigationManager = NavigationManager.shared
    
    @ObservedObject private var status = StatusManager.shared
    
    let description: String = "탭해서 점령전 시작하기"
    
    var body: some View {
        let team = status.userStatus.userTeam.lowercased()

        ZStack {
            Image("bg_team_assignment")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .all)
                .offset(y: 100)
            
            // 기차
            switch team {
            case "blue":
                Image("train_blue")
                    .resizable()
                    .scaledToFit()
                    .offset(x: 20, y: 86)
                
            case "yellow":
                Image("train_yellow")
                    .resizable()
                    .scaledToFit()
                    .offset(x: 20, y: 86)
                
            default:
                // 디버그 폴백
                Text("팀 정보를 불러오는 중… (\(team))")
                    .font(.PR.body2)
                    .foregroundStyle(.white)
                    .padding(.top, 80)
            }
            
            // 타이틀
            VStack {
                switch team {
                case "blue":
                    TitleSectionView(title: "당신은 파랑팀입니다!", description: description)
                        .padding(.top, 50)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                case "yellow":
                    TitleSectionView(title: "당신은 노랑팀입니다!", description: description)
                        .padding(.top, 50)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                default:
                    EmptyView()
                }
            }
        }
        .contentShape(Rectangle()) // ZStack 전체 터치 영역 활성화
        .onAppear {
            print("🔎 TeamAssignmentView team = '\(status.userStatus.userTeam)'")
        }
        .onTapGesture {
            UserDefaults.standard.hasSeenTeamAssignment = true // 앞으로 앱 진입 시 TeamAssignmentView 건너 뛰기 (setRootView에서 관리)
            navigationManager.replaceRoot(with: .main)
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
