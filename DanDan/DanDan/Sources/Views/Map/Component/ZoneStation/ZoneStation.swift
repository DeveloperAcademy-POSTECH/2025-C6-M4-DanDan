////
////  ZoneStation.swift
////  DanDan
////
////  Created by soyeonsoo on 11/7/25.
////
//
//import SwiftUI
//
//struct ZoneStation: View {
//    let zone: Zone
//    let statusesForZone: [ZoneConquestStatus]
//    
//    let zoneTeamScores: [Int: [ZoneTeamScoreDTO]]
//    let loadZoneTeamScores: (Int) -> Void
//    
//    @State private var showPopover = false
//    var iconSize: CGSize = CGSize(width: 68, height: 74)
//    var popoverOffsetY: CGFloat = -100
//    
//    var body: some View {
//        ZStack {
//            // 정류소 버튼 (다시 누르면 닫힘)
//            Button {
//                withAnimation(.spring(response: 0.7, dampingFraction: 1)) {
//                    showPopover.toggle()
//                }
//            } label: {
//                Image("zone_station")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: iconSize.width, height: iconSize.height)
//                    .accessibilityLabel("정류소")
//                    .shadow(color: .black.opacity(0.4), radius: 8, x: 6, y: 4)
//            }
//            .buttonStyle(.plain)
//            
//            // 정류소 버튼 위에 뜨는 커스텀 팝오버
//            if showPopover {
//                ZoneStationSign(
//                    zone: zone,
//                    statusesForZone: statusesForZone,
//                    zoneTeamScores: zoneTeamScores,
//                    loadZoneTeamScores: loadZoneTeamScores
//                )
//                .fixedSize()
//                .offset(y: popoverOffsetY)
//                .contentShape(Rectangle())
//                .transition(.move(edge: .top).combined(with: .opacity))
//                .zIndex(2)
//                .onTapGesture {
//                    withAnimation(.easeOut(duration: 1.2)) { showPopover = false }
//                }
//            }
//        }
//        .zIndex(showPopover ? 3 : 2)
//    }
//}
