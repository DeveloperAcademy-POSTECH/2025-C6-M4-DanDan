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
                userTeam: "",
                userWeekScore: 0,
                userDailyScore: 0,
                zoneCheckeStatus: [:],
                rank: 0
            )
            save()
        }
    }
    
    /// 사용자의 일일 및 주간 점수를 획득한 점수만큼 증가시킵니다.
    func incrementDailyScore() {
        userStatus.userDailyScore += 1
        userStatus.userWeekScore += 1
        save()
    }
    
    /// 사용자가 오늘 해당 구간을 지나갔다면, 체크 상태로 저장합니다.
    /// - Parameters:
    ///     - zoneId: 체크할 구간의 고유 ID
    ///     - checked: 구간을 지났는지 여부 (true: 지나감)
    func setZoneChecked(zoneId: Int, checked: Bool) {
        userStatus.zoneCheckeStatus[zoneId] = checked
        save()
    }
        save()
    }

    /// 랜덤으로 팀을 배정합니다.
    func assignRandomTeamForThisWeek() {
        guard userStatus.userTeam.isEmpty else { return }
        let random = TeamType.allCases.randomElement()!
        userStatus.userTeam = random.rawValue
        save()
    }
    
    /// 주간/일일 점령전 상태 (UserStatus)를 저장합니다.
    private func save() {
        if let data = try? JSONEncoder().encode(userStatus) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}
