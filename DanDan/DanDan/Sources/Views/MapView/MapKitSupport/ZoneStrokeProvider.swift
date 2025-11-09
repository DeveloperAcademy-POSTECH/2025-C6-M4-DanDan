//
//  ZoneStrokeProvider.swift
//  DanDan
//
//  Created by soyeonsoo on 11/9/25.
//

import UIKit

struct ZoneStrokeProvider {
    let zoneStatuses: [ZoneStatus]

    func stroke(for zoneId: Int, isOutline: Bool) -> UIColor {
        if isOutline {
            let checked = StatusManager.shared.userStatus.zoneCheckedStatus[zoneId] == true
            return checked ? UIColor.white.withAlphaComponent(0.85) : UIColor.clear
        } else {
            return ZoneColorResolver.leadingColorOrDefault(
                for: zoneId,
                zoneStatuses: zoneStatuses,
                defaultColor: .primaryGreen
            )
        }
    }
}
