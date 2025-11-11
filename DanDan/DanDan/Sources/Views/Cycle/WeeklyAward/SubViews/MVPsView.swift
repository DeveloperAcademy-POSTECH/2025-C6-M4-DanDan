//
//  MVPsView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import SwiftUI

// 우승 팀에서의 개인 랭킹 순위로 15위까지 표시
struct MVPsView: View {
    let mvps: [MVP]   // 최대 15개 사용
    
    // 1위~15위 크기 맵핑
    private func size(for rank: Int) -> CGFloat {
        switch rank {
        case 1: return 52
        case 2...3: return 44
        case 4...9: return 32
        default: return 24
        }
    }
    
    private var rows: [[MVP]] {
        let top15 = Array(mvps.sorted { $0.rank < $1.rank }.prefix(15))
        let counts = [2, 4, 5, 4]
        var cursor = 0
        return counts.map { c in
            let slice = Array(top15.dropFirst(cursor).prefix(c))
            cursor += slice.count
            return slice
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 16) {
                    ForEach(row) { mvp in
                        AvatarCircle(imageName: mvp.imageName,
                                     size: size(for: mvp.rank))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
            }
        }
        .padding(.top, 14)
    }
}
