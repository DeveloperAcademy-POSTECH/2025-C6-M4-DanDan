//
//  ZoneDebugEvents.swift
//  DanDan
//
//  Created by Assistant on 11/13/25.
//
//  디버깅용: 구역 추적/완료 진행 상황을 Notification으로 브로드캐스트
//

import Foundation
import CoreLocation

enum ZoneDebugEvents {
    static let currentIndexChanged = Notification.Name("ZoneDebug.currentIndexChanged")
    static let progressUpdated     = Notification.Name("ZoneDebug.progressUpdated")
    static let zoneCompleted       = Notification.Name("ZoneDebug.zoneCompleted")
    
    enum Key {
        static let zoneIndex = "zoneIndex"            // Int
        static let entryIsStart = "entryIsStart"      // Bool
        static let forwardMeters = "forwardMeters"    // Double
        static let minForwardMeters = "minForwardMeters" // Double
        static let exitEntered = "exitEntered"        // Bool
        static let location = "location"              // CLLocation
        static let zoneId = "zoneId"                  // Int
        static let timestamp = "timestamp"            // Date
        static let switchedFromIndex = "switchedFromIndex" // Int?
    }
}


