//
//  WeeklyAwardView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import SwiftUI

struct MVP: Identifiable, Hashable {
    let id = UUID()
    let rank: Int
    let imageName: String
}

struct WeeklyAwardView: View {
    private let navigationManager = NavigationManager.shared
    
    // TODO: 외부에서 주입 필요
    var winnerTeamName: String?
    
    var conqueredZones: Int?
    
    // TODO: rank, imageName 주입 필요
    private let demoMVPs: [MVP] = (1...15).map {
        MVP(rank: $0, imageName: "default_avatar") // 더미 데이터
    }
    
    private var winnerTitle: String {
        switch winnerTeamName?.lowercased() {
        case "blue":   return "파랑팀 우승!"
        case "yellow": return "노랑팀 우승!"
        default:       return "두구두구"
        }
    }
    
    var body: some View {
        VStack {
            WeeklyAwardTitleSectionView(
                title: winnerTitle,
                description: "총 \(conqueredZones!)구역을 점령했어요\n테스트 참여 감사해요 더 좋은 앱으로 돌아올게요"
            )
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .top)
            
            Image("trophy")
                .resizable()
                .scaledToFit()
                .frame(width: 230)
                .padding(.top, 20)
            
            MVPsView(mvps: demoMVPs)
            
            Spacer()
            
            PrimaryButton(
                "그래도 스틸워크와 계속 걷기",
                action: {
                    navigationManager.navigate(to: .main)
                }
            )
        }
    }
}

#Preview("Yellow") {
    WeeklyAwardView(winnerTeamName: "yellow", conqueredZones: 9)
}
