//
//  MapToggleView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/2/25.
//

import SwiftUI
import MapKit

struct MapToggleView: View {
    @State private var isFullMap = false
    
    var conquestStatuses: [ZoneConquestStatus]
    var teams: [Team]
    
    var body: some View {
        ZStack {
            Group {
                if isFullMap {
                    FullMapView(
                        conquestStatuses: conquestStatuses,
                        teams: teams
                    ) // 2D 전체 지도뷰
                } else {
                    MapView(
                        conquestStatuses: conquestStatuses,
                        teams: teams
                    ) // 3D 부분 지도뷰
                }
            }
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.snappy(duration: 0.25)) {
                            isFullMap.toggle()
                        }
                    } label: {
                        Image(systemName: "globe.central.south.asia.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(isFullMap ? .primaryGreen : .steelBlack)
                            .frame(width: 56, height: 56)
                    }
                    .buttonStyle(.plain)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(.white.opacity(0.4), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                    .padding(.trailing, 20)
                }
                .padding(.top, 100)
                
                Spacer()
            }
        }
    }
}
