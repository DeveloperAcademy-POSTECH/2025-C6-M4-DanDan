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
            Text("\(l) : \(r)")
                .font(.PR.body2)
                .foregroundStyle(.gray)
        } else {
            Text("— : —")
                .font(.PR.body2)
                .foregroundStyle(.gray)
        }
    }
}
