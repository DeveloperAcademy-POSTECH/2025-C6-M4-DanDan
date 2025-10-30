//
//  ZoneBadgeView.swift
//  DanDan
//
//  Created by soyeonsoo on 10/26/25.
//

import SwiftUI

struct ZoneBadgeView: View {
    var number: Int
    var teamColor: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(teamColor)
                .overlay(
                    Circle().stroke(.white, lineWidth: 2)
                )
                .frame(width: 30, height: 30)
            Text("\(number)")
                .font(.system(size: 15))
                .foregroundStyle(.white)
        }
        .contentShape(Circle())
    }
}

#Preview {
    ZoneBadgeView(number: 3, teamColor: .indigo)
}
