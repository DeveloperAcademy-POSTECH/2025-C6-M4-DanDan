//
//  ZoneInfoTitle.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/15/25.
//

import SwiftUI

struct ZoneInfoTitle: View {
    let zoneId: Int
    let zoneName: String

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "\(zoneId).circle")
                .font(.system(size: 17, weight:.semibold))
                .foregroundColor(.steelBlack)
            
            Text(zoneName)
                .font(.PR.title2)
                .foregroundColor(.steelBlack)
        }
    }
}
