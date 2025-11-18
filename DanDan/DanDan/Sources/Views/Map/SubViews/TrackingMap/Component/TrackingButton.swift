//
//  TrackingButton.swift
//  DanDan
//
//  Created by soyeonsoo on 11/18/25.
//

import SwiftUI

struct TrackingButton: View {
    @Binding var isTracking: Bool
    var restoreTracking: () -> Void
    
    var body: some View {
        Button {
            restoreTracking()
        } label: {
            Image(systemName: "location.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isTracking ? .primaryGreen : .steelBlack)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .background(.ultraThinMaterial, in: Circle())
        .overlay(
            Circle()
                .strokeBorder(.white.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        .padding(.trailing, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}
