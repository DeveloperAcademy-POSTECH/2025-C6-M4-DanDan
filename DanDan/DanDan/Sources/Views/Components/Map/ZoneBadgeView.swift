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
                .stroke(.white, lineWidth: 2)
                .frame(width: 30, height: 30)
            Text("\(number)")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
        }
        .contentShape(Circle())
    }
}

#Preview {
    ZoneBadgeView(number: 3, teamColor: .indigo)
}
