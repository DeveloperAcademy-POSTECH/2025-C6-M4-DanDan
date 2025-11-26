//
//  ZoneInfoScore.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/15/25.
//

import SwiftUI

struct ZoneInfoScore: View {
    let teamScores: [ZoneTeamScoreDTO]

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(teamScores.indices, id: \.self) { idx in
                    Text(teamScores[idx].teamName.teamDisplayName)
                        .font(.PR.caption3)
                        .foregroundColor(.gray1)
                }
            }

            HStack(spacing: 0) {
                if teamScores.isEmpty {
                    Text("— : —")
                        .font(.PR.title1)
                        .foregroundColor(.darkGreen)
                } else {
                    Text(teamScores
                        .map { String($0.totalScore) }
                        .joined(separator: " : "))
                        .font(.PR.title1)
                        .foregroundColor(.darkGreen)
                }
            }
        }
    }
}
