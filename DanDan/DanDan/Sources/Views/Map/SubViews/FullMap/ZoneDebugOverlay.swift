//
//  ZoneDebugOverlay.swift
//  DanDan
//
//  Created by Assistant on 11/13/25.
//

import SwiftUI
import CoreLocation

#if DEBUG
struct ZoneDebugOverlay: View {
    @State private var isExpanded: Bool = true
    @State private var currentIndex: Int?
    @State private var entryIsStart: Bool?
    @State private var forwardMeters: Double = 0
    @State private var minForwardMeters: Double = 10
    @State private var exitEntered: Bool = false
    @State private var lastCompletedZoneId: Int?
    @State private var lastUpdatedAt: Date?
    @State private var switchedFrom: Int?
    
    private var checkedCount: Int {
        StatusManager.shared.userStatus.zoneCheckedStatus.values.filter { $0 == true }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Zone Debug")
                    .font(.PR.caption1)
                    .foregroundStyle(.white)
                Spacer()
                Button(action: { isExpanded.toggle() }) {
                    Text(isExpanded ? "Hide" : "Show")
                        .font(.PR.caption3)
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .padding(.bottom, isExpanded ? 4 : 0)
            
            if isExpanded {
                Group {
                    HStack(spacing: 10) {
                        Text("currentIndex: \(currentIndex.map(String.init) ?? "nil")")
                        Text("entry: \(entryIsStart == true ? "start→end" : (entryIsStart == false ? "end→start" : "nil"))")
                    }
                    .font(.PR.caption3)
                    .foregroundStyle(.white)
                    
                    HStack(spacing: 10) {
                        Text(String(format: "forward: %.1fm", forwardMeters))
                        Text(String(format: "min: %.1fm", minForwardMeters))
                        Text("exitEntered: \(exitEntered ? "true" : "false")")
                    }
                    .font(.PR.caption3)
                    .foregroundStyle(exitEntered ? .green : .white)
                    
                    if let switchedFrom {
                        Text("switched from: \(switchedFrom) → \(currentIndex.map(String.init) ?? "?")")
                            .font(.PR.caption3)
                            .foregroundStyle(.yellow)
                    }
                    
                    if let lastCompletedZoneId {
                        Text("completed zoneId: \(lastCompletedZoneId)")
                            .font(.PR.caption3)
                            .foregroundStyle(.green)
                    }
                    
                    if let t = lastUpdatedAt {
                        Text("updated: \(t.formatted(date: .omitted, time: .standard))")
                            .font(.PR.caption4)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    
                    Divider().background(.white.opacity(0.2))
                    
                    Text("checked today: \(checkedCount)")
                        .font(.PR.caption3)
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.trailing, 12)
        .padding(.top, 60)
        .onReceive(NotificationCenter.default.publisher(for: ZoneDebugEvents.currentIndexChanged)) { n in
            currentIndex = n.userInfo?[ZoneDebugEvents.Key.zoneIndex] as? Int
            entryIsStart = n.userInfo?[ZoneDebugEvents.Key.entryIsStart] as? Bool
            switchedFrom = n.userInfo?[ZoneDebugEvents.Key.switchedFromIndex] as? Int
            lastUpdatedAt = n.userInfo?[ZoneDebugEvents.Key.timestamp] as? Date
        }
        .onReceive(NotificationCenter.default.publisher(for: ZoneDebugEvents.progressUpdated)) { n in
            currentIndex = n.userInfo?[ZoneDebugEvents.Key.zoneIndex] as? Int
            entryIsStart = n.userInfo?[ZoneDebugEvents.Key.entryIsStart] as? Bool
            forwardMeters = (n.userInfo?[ZoneDebugEvents.Key.forwardMeters] as? Double) ?? 0
            minForwardMeters = (n.userInfo?[ZoneDebugEvents.Key.minForwardMeters] as? Double) ?? 10
            exitEntered = (n.userInfo?[ZoneDebugEvents.Key.exitEntered] as? Bool) ?? false
            lastUpdatedAt = n.userInfo?[ZoneDebugEvents.Key.timestamp] as? Date
            switchedFrom = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: ZoneDebugEvents.zoneCompleted)) { n in
            lastCompletedZoneId = n.userInfo?[ZoneDebugEvents.Key.zoneId] as? Int
            lastUpdatedAt = n.userInfo?[ZoneDebugEvents.Key.timestamp] as? Date
        }
    }
}
#endif


