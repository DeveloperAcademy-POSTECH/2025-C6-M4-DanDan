//
//  TeamAssignmentView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import Lottie
import SwiftUI

struct TeamAssignmentView: View {
    private let navigationManager = NavigationManager.shared
    
    @ObservedObject private var status = StatusManager.shared
    
    let description: String = "탭해서 점령전 시작하기"
    
    var body: some View {
        let team = status.userStatus.userTeam.lowercased()

        ZStack {
            switch team {
            case "blue":
                LottieOnceView(name: "assign_blue_team")
                    .offset(y: 5)
                    .ignoresSafeArea()

                
            case "yellow":
                LottieOnceView(name: "assign_yellow_team")
                    .offset(y: 5)
                    .ignoresSafeArea()
                
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
                    TitleSectionView(title: "당신은 파랑팀입니다!\n세명고등학교", description: description)
                        .padding(.top, 50)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                case "yellow":
                    TitleSectionView(title: "당신은 노랑팀입니다!\n대동중 X 이동고", description: description)
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

#Preview("Team Assignment") {
    TeamAssignmentView()
        .onAppear {
            StatusManager.shared.userStatus.userTeam = "yellow"
        }
}
