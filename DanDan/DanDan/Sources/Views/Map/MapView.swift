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
    @State private var refreshToken: UUID = .init()
    
    var conquestStatuses: [ZoneConquestStatus]
    var teams: [Team]
    
    var body: some View {
        ZStack {
            Group {
                if isFullMap {
                    FullMapScreen( // 2D 전체 지도뷰
                        conquestStatuses: conquestStatuses,
                        teams: teams,
                        refreshToken: refreshToken,
                        userStatus: StatusManager.shared.userStatus
                    )
                } else {
                    TrackingMapScreen( // 3D 부분 지도뷰
                        conquestStatuses: conquestStatuses,
                        teams: teams,
                        userStatus: StatusManager.shared.userStatus,
                        period: StatusManager.shared.currentPeriod,
                        refreshToken: refreshToken
                    )
                }
            }
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
                var didChange = false
                for (zoneId, isChecked) in current where isChecked == true {
                    if lastChecked[zoneId] != true {
                        StatusManager.shared.setZoneChecked(zoneId: zoneId, checked: true)
                        didChange = true
                    }
                }
                lastChecked = current
                if didChange {
                    refreshToken = UUID()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: StatusManager.didResetNotification)) { _ in
                // 로그인/로그아웃 등으로 로컬 상태가 리셋되면, 트래커/캐시/토큰도 동기화
                let status = StatusManager.shared.userStatus
                self.tracker = ZoneTrackerManager(zones: zones, userStatus: status)
                self.lastChecked = [:]
                self.refreshToken = UUID()
            }
            
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.top, 114)
        }
    }
}

