//
//  MVPsView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import SwiftUI

// 우승 팀에서의 개인 랭킹 순위로 15위까지 표시
struct MVPsView: View {
    let mvps: [MVP]
    
    // 1위~15위 크기 맵핑
    private func size(for rank: Int) -> CGFloat {
        switch rank {
        case 1: return 52
        case 2...3: return 44
        case 4...9: return 32
        default: return 24
        }
    }
    
    /// 정렬은 랭킹 기준, 배치는 오프셋으로 컨트롤
    private var top15: [MVP] {
        Array(mvps.sorted { $0.rank < $1.rank }.prefix(15))
    }
    
    /// 각 인덱스별 오프셋 프리셋
    private func bubbleOffset(for index: Int) -> CGSize {
        let presets: [CGSize] = [
            .init(width: -46,  height: -40),  // 1위
            .init(width: 60,   height: 66),
            .init(width: -70,  height: 20),
            .init(width: 100,   height: -24),
            .init(width: 5,   height: -20),
            .init(width: -76,  height: 76),
            .init(width: -18,  height: 20),
            .init(width: 40,   height: 10),
            .init(width: -28,  height: 66),
            .init(width: -100, height: -24),
            .init(width: 86,  height: 25),
            .init(width: 46,   height: -36),
            .init(width: 16,   height: 50),
            .init(width: 10,  height: 95),
            .init(width: 110,  height: 76),
        ]
        
        if index < presets.count {
            return presets[index]
        } else {
            return .zero
        }
    }
    
    var body: some View {
        ZStack {
            ForEach(Array(top15.enumerated()), id: \.element.id) { index, mvp in
                AvatarCircle(
                    imageName: mvp.imageName,
                    size: size(for: mvp.rank)
                )
                .offset(bubbleOffset(for: index))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 180, idealHeight: 220)
    }
}
