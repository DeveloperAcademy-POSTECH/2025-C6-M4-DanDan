//
//  MapToggleView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/2/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapToggleView: View {
    @State private var isFullMap = false
    @StateObject private var locationService = LocationService()
    @State private var tracker: ZoneTrackerManager?
    @State private var lastChecked: [Int: Bool] = [:]
    
    
    var body: some View {
        ZStack {
            Group {
                if isFullMap {
                    FullMapView() // 2D 전체 지도뷰
                } else {
                    MapView() // 3D 부분 지도뷰
                }
            }
            .ignoresSafeArea()
            .onAppear {
                if tracker == nil {
                    // 현재 저장된 사용자 상태로 트래커 초기화
                    let status = StatusManager.shared.userStatus
                    let t = ZoneTrackerManager(zones: zones, userStatus: status)
                    self.tracker = t
                    self.lastChecked = status.zoneCheckedStatus
                }
            }
            .onReceive(locationService.$currentLocation.compactMap { $0 }) { loc in
                guard let tracker = tracker else { return }
                // 위치 업데이트 처리
                tracker.process(location: loc)

                // 변경된 체크 상태를 StatusManager에 반영
                let current = tracker.userStatus.zoneCheckedStatus
                for (zoneId, isChecked) in current where isChecked == true {
                    if lastChecked[zoneId] != true {
                        StatusManager.shared.setZoneChecked(zoneId: zoneId, checked: true)
                    }
                }
                lastChecked = current
            }
            
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
                        
                            // TODO: 컬러셋 추가 후 활성화 시 아이콘 색상 변경
                        
                            .foregroundStyle(isFullMap ? .red : .black)
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

#Preview{
    MapToggleView()
}
