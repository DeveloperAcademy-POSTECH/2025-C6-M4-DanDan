//
//  ZoneInfoDescription.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/15/25.
//

import SwiftUI

struct ZoneInfoDescription: View {
    let descriptionText: String

    var body: some View {
        Text(descriptionText)
            .font(.PR.caption3)
            .foregroundColor(.gray1)
            .frame(maxWidth: .infinity)
    }
}
