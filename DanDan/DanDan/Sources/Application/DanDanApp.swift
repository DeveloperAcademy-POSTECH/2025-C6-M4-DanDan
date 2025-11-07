//
//  DanDanApp.swift
//  DanDan
//
//  Created by Jay on 10/25/25.
//

import SwiftUI

@main
struct DanDanApp: App {
    @Environment(\.scenePhase) private var scenePhase
    private let lastDailySyncKey = "lastDailySyncDate"

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { newPhase in
            guard newPhase == .active else { return }
            handleDailySyncIfNeeded()
        }
    }

    /// 앱이 활성화될 때 하루가 바뀌었으면 로컬 상태를 리셋하고 서버에서 오늘 완료 구역을 동기화합니다.
    private func handleDailySyncIfNeeded() {
        let now = Date()
        let cal = Calendar.current
        let last = UserDefaults.standard.object(forKey: lastDailySyncKey) as? Date
        if let last, cal.isDate(last, inSameDayAs: now) {
            return // 같은 날이면 스킵
        }

        // 1) 로컬 일일 상태 리셋
        StatusManager.shared.resetDailyStatus()

        // 2) 서버에서 오늘 완료 구역 조회 → 3) 로컬 재표기
        ZoneCheckedService.shared.fetchTodayCheckedZoneIds { ids in
            ids.forEach { id in
                StatusManager.shared.setZoneChecked(zoneId: id, checked: true)
            }
            // 동기화 시점 저장
            UserDefaults.standard.set(now, forKey: lastDailySyncKey)
            // 4) UI 갱신 알림
            NotificationCenter.default.post(name: StatusManager.didResetNotification, object: nil)
        }
    }
}
