//
//  ZoneHeaderView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/2/25.
//

import SwiftUI

struct ZoneStationSignHeader: View {
    let zoneId: Int
    let zoneName: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(zoneId)")
                .font(.PR.body2)
                .frame(width: 28, height: 28)
                .background(Circle().fill(.clear))
                .overlay(Circle().stroke(.black, lineWidth: 2))
            
            Text(zoneName)
                .font(.PR.body2)
                .foregroundStyle(.black)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}
