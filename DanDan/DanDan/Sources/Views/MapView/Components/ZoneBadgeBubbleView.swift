//
//  ZoneBadgeBubbleView.swift
//  DanDan
//
//  Created by soyeonsoo on 10/29/25.
//

import SwiftUI

struct ZoneInfoBubbleView: View {
    let zoneName: String
    let blueScore: Int
    let whiteScore: Int

    var body: some View {
        VStack(spacing: 6) {
            Text(zoneName)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
            HStack(spacing: 10) {
                    Text("\(blueScore)  :  \(whiteScore)")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
        )
    }
}

//#Preview {
//    ZoneInfoBubbleView(zoneName: "상생숲길 1구역", blueScore: 8, whiteScore: 5)
//}
