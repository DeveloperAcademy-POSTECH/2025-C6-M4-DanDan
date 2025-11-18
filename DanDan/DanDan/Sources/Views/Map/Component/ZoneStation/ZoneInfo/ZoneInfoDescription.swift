//
//  ZoneInfoDescription.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/15/25.
//

import SwiftUI

struct ZoneInfoDescription: View {
    let distance: Int
    let descriptionText: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text("\(distance)m")
                .font(.PR.caption3)
                .foregroundColor(.gray1)
                .frame(height: 22)
            
            Text(descriptionText)
                .font(.PR.caption3)
                .foregroundColor(.gray1)
                .frame(height: 22)
            
        }
        .frame(maxWidth: .infinity)
    }
}
