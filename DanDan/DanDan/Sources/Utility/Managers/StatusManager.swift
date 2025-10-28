//
//  StatusManager.swift
//  DanDan
//
//  Created by Jay on 10/28/25.
//

import Foundation

class StatusManager {
    static let shared = StatusManager()

    @Published var userStatus: UserStatus

    private let userDefaultsKey = "userStatus"

    init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let saved = try? JSONDecoder().decode(UserStatus.self, from: data) {
            self.userStatus = saved
        } else {
            self.userStatus = UserStatus(
                id: UUID(),
                userWeekScore: 0,
                userDailyScore: 0,
                isZoneChecked: false,
                rank: 0
            )
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(userStatus) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}
