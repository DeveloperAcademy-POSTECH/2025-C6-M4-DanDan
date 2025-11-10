//
//  ZoneStation.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import SwiftUI

struct ZoneStation: View {
    @ObservedObject var viewModel: MapScreenViewModel
    @State private var showPopover = false

    let zone: Zone
    let statusesForZone: [ZoneConquestStatus]
    
    var iconSize: CGSize = CGSize(width: 68, height: 74)
    var popoverOffsetY: CGFloat = -100
    
    var body: some View {
        ZStack {
            // 정류소 버튼 (다시 누르면 닫힘)
            Button {
                withAnimation(.spring(response: 0.7, dampingFraction: 1)) {
                    showPopover.toggle()
                }
            } label: {
                Image("zone_station")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize.width, height: iconSize.height)
                    .accessibilityLabel("정류소")
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 6, y: 4)
            }
            .buttonStyle(.plain)
            
            // 정류소 버튼 위에 뜨는 커스텀 팝오버
            if showPopover {
                ZoneStationSign(viewModel: viewModel, zone: zone, statusesForZone: statusesForZone)
                    .fixedSize()
                    .offset(y: popoverOffsetY)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(2)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 1.2)) { showPopover = false }
                    }
            }
        }
    }
}

#Preview {
    // 더미 데이터
    let dummyZone = Zone(
        zoneId: 10,
        zoneName: "추억의 길 1구역",
        coordinates: [
            .init(latitude: 36.029071, longitude: 129.355408),
            .init(latitude: 36.030591, longitude: 129.356849)
        ],
        zoneColor: .white
    )
    let s1 = ZoneConquestStatus(zoneId: 10, teamId: 1, teamName: "파랑",   teamScore: 12)
    let s2 = ZoneConquestStatus(zoneId: 10, teamId: 2, teamName: "노랑", teamScore: 8)
    
    return ZoneStation(viewModel: MapScreenViewModel(), zone: dummyZone, statusesForZone: [s1, s2])
}
