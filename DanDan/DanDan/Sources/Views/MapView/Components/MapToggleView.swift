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
    @State private var renderToken = UUID()
    @State private var debugMessage: String? = nil
    @ObservedObject private var zoneState = ZoneCheckedStateManager.shared
    
    private func showDebug(_ message: String) {
        debugMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.2)) {
                debugMessage = nil
            }
        }
    }
    
    var conquestStatuses: [ZoneConquestStatus]
    var teams: [Team]
    
    var body: some View {
        ZStack {
            Group {
                if isFullMap {
                    FullMapScreen( // 2D 전체 지도뷰
                        conquestStatuses: conquestStatuses,
                        teams: teams,
                        refreshToken: zoneState.version,
                      userStatus: StatusManager.shared.userStatus
                    ) // 2D 전체 지도뷰


                } else {
                    MapScreen( // 3D 부분 지도뷰
                        conquestStatuses: conquestStatuses,
                        teams: teams,
                        refreshToken: zoneState.version,
                        userStatus: StatusManager.shared.userStatus,
                        period: StatusManager.shared.currentPeriod
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
            .onReceive(locationService.$currentLocation) { loc in
                guard let tracker = tracker, let loc = loc else { return }
                // 위치 업데이트 처리
                tracker.process(location: loc)
                
                // 변경된 체크 상태를 StatusManager에 반영
                let current = tracker.userStatus.zoneCheckedStatus
                for (zoneId, isChecked) in current where isChecked == true {
                    if lastChecked[zoneId] != true {
                        zoneState.onComplete(zoneId: zoneId) { ok in
                            if ok { self.showDebug("전송 성공: zoneId=\(zoneId)") }
                            else { self.showDebug("전송 실패: zoneId=\(zoneId)") }
                        }
                    }
                }
                lastChecked = current
            }
            
            VStack {
                HStack {
                    Spacer()
                    // FullMap 화면의 개인/전체 토글은 FullMapScreen 내부 SegmentedControl에서 처리
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

            // Debug banner (top)
            VStack(spacing: 0) {
                if let msg = debugMessage {
                    Text(msg)
                        .font(.PR.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.75))
                        )
                        .padding(.top, 60)
                        .transition(.opacity)
                }
                Spacer()
            }
        }
    }
}

