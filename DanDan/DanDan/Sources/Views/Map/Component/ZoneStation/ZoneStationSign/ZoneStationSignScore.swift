//
//  ZoneScoreView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/2/25.
//

import SwiftUI

struct ZoneScoreView: View {
    let scorePair: ZoneScorePair

    var body: some View {
        if let l = scorePair.leftScore, let r = scorePair.rightScore {
            HStack {
                Text("\(scorePair.leftTeamName ?? "A")")
                    .font(.PR.caption5)
                    .foregroundColor(.gray3)
                Text("\(l) : \(r)")
                    .font(.PR.body2)
                    .foregroundColor(.gray2)
                Text("\(scorePair.rightTeamName ?? "B")")
                    .font(.PR.caption5)
                    .foregroundColor(.gray3)
            }
        } else {
            Text("— : —")
                .font(.PR.body2)
                .foregroundStyle(.gray)
        }
    }
}
