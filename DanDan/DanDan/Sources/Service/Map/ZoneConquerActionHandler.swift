//
//  ZoneConquerActionHandler.swift
//  DanDan
//
//  Created by soyeonsoo on 11/9/25.
//

final class ZoneConquerActionHandler {
    static func handleConquer(zoneId: Int) {
        ZoneCheckedService.shared.postChecked(zoneId: zoneId) { ok in
            guard ok else { print("🚨 postChecked failed: \(zoneId)"); return }
            ZoneCheckedService.shared.acquireScore(zoneId: zoneId) { ok2 in
                if ok2 {
                    StatusManager.shared.incrementDailyScore()
                    StatusManager.shared.setRewardClaimed(zoneId: zoneId, claimed: true)
                } else {
                    print("🚨 acquireScore failed: \(zoneId)")
                }
            }
        }
    }
}
