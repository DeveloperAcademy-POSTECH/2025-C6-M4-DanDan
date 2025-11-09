//
//  MyRankBadgeView.swift
//  DanDan
//
//  Created by Jay on 11/4/25.
//

import SwiftUI

// TODO: 추후 'DesignSystem/Component' 폴더로 배지 UI 관리
struct MyRankBadgeView: View {
    var body: some View {
        Text("나")
            .font(.pretendard(.extraBold, size: 10))
            .foregroundStyle(.white)
            .frame(width: 16, height: 16)
            .background(Circle().fill(Color.darkGreen))
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .padding(-0.4) // 프레임 바깥으로 스트로크 적용
                )
    }
}
