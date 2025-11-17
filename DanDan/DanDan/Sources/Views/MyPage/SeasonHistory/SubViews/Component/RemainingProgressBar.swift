//
//  RemainingProgressBar.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/4/25.
//

import SwiftUI

/// 이미지처럼 보이는 진행 슬라이더(읽기 전용)
struct RemainingProgressBar: View {
    /// 0.0 ~ 1.0
    var progress: Double
    /// 오른쪽에 표시할 텍스트 (예: "3일 9시간 남음")
    var trailingText: String

    var trackHeight: CGFloat = 10
    
    private var teamBarColor: Color {
        let team = StatusManager.shared.userStatus.userTeam.lowercased()
        return team == "blue" ? .A : .B
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // 오른쪽 남은 시간 텍스트
            Text(trailingText)
                .font(.PR.caption4)
                .foregroundStyle(.gray3)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.gray5)
                        .frame(height: trackHeight)

                    Capsule()
                        .fill(teamBarColor)
                        .frame(
                            width: max(0, min(1, progress)) * geo.size.width,
                            height: trackHeight
                        )
                }
            }
            .frame(height: trackHeight)
            .clipped()
            .animation(.easeInOut(duration: 0.25), value: progress)
        }
    }
}


