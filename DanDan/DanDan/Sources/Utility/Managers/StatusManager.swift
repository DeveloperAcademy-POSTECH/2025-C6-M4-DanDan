//
//  StatusManager.swift
//  DanDan
//
//  Created by Jay on 10/28/25.
//

import Foundation

class StatusManager: ObservableObject {
    static let shared = StatusManager()
    static let didResetNotification = Notification.Name("UserStatusDidReset")

    @Published var userStatus: UserStatus {
        didSet {
            save()
            print("[StatusManager] userStatus changed — team='\(userStatus.userTeam)' daily=\(userStatus.userDailyScore) week=\(userStatus.userWeekScore)")
        }
    }
    @Published var zoneStatuese: [ZoneConquestStatus] = []
    @Published var currentPeriod: ConquestPeriod = .init(startDate: Date())

    private let userDefaultsKey = "userStatus"

    init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let saved = try? JSONDecoder().decode(UserStatus.self, from: data)
        {
            self.userStatus = saved
        } else {
            self.userStatus = UserStatus()
            save()
        }
        print("[StatusManager] initialized — loaded team='\(userStatus.userTeam)'")
    }

    // MARK: - Team Helpers
    private func normalizeTeamName(_ raw: String) -> String {
        let lower = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch lower {
        case "blue":   return "Blue"
        case "yellow": return "Yellow"
        default:       return raw
        }
    }
    
    /// userTeam이 비어 있을 경우 서버의 마이페이지 API에서 팀을 로드하여 보정합니다.
    func ensureUserTeamLoaded() async {
        guard userStatus.userTeam.isEmpty else { return }
        print("[StatusManager] userTeam empty — fetching from MyPage API")
        do {
            let service = MyPageService()
            let resp = try await service.fetchMyPage()
            let team = normalizeTeamName(resp.data.user.userTeam)
            if !team.isEmpty {
                userStatus.userTeam = team
                print("[StatusManager] userTeam loaded from API — team='\(team)'")
            } else {
                print("[StatusManager] API returned empty team — keeping empty")
            }
        } catch {
            print("[StatusManager] failed to load team from API: \(error)")
        }
    }

    /// 사용자의 일일 및 주간 점수를 획득한 점수만큼 증가시킵니다.
    func incrementDailyScore() {
        userStatus.userDailyScore += 1
        userStatus.userWeekScore += 1
    }

    /// 사용자가 오늘 해당 구간을 지나갔다면, 체크 상태로 저장합니다.
    /// - Parameters:
    ///     - zoneId: 체크할 구간의 고유 ID
    ///     - checked: 구간을 지났는지 여부 (true: 지나감)
    func setZoneChecked(zoneId: Int, checked: Bool) {
        userStatus.zoneCheckedStatus[zoneId] = checked
    }

    /// 하루가 지나면 전체 구간의 체크 상태를 초기화합니다.
    func resetDailyStatus() {
        userStatus.userDailyScore = 0
        userStatus.zoneCheckedStatus = [:]
        userStatus.rewardClaimedStatus = [:]
    }

    // TODO: 팀 균형 배정을 위한 로직으로 개선 예정 (현재는 단순 무작위 배정)
    /// 랜덤으로 팀을 배정합니다.
    func assignRandomTeamForThisWeek() {
        guard userStatus.userTeam.isEmpty else { return }
        let random = TeamType.allCases.randomElement()!
        userStatus.userTeam = random.rawValue
    }

    /// 주간/일일 점령전 상태 (UserStatus)를 저장합니다.
    private func save() {
        if let data = try? JSONEncoder().encode(userStatus) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    // MARK: - Reward Claim Helpers
    /// 오늘 해당 구역의 보상을 이미 수령했는지 여부를 반환합니다.
    func isRewardClaimed(zoneId: Int) -> Bool {
        return userStatus.rewardClaimedStatus?[zoneId] == true
    }

    /// 오늘 해당 구역의 보상 수령 여부를 설정합니다.
    func setRewardClaimed(zoneId: Int, claimed: Bool) {
        if userStatus.rewardClaimedStatus == nil {
            userStatus.rewardClaimedStatus = [:]
        }
        userStatus.rewardClaimedStatus?[zoneId] = claimed
    }

    /// 기존 유저의 ID를 유지한 채 UserStatus 상태를 초기화합니다.
    func resetUserStatus() {
        userStatus = UserStatus(from: userStatus)
        NotificationCenter.default.post(name: Self.didResetNotification, object: nil)
    }

    /// 모든 구간의 점령 상태를 초기화합니다.
    func resetZoneConquestStatus() {
        zoneStatuese = zoneStatuese.map { ZoneConquestStatus(zoneId: $0.zoneId) }
    }

    /// 새로운 점령 기간을 시작합니다.
    ///
    /// - Note: 이전 주차 데이터를 스냅샷으로 저장한 뒤,
    ///   새로운 기간(`ConquestPeriod`)을 생성하고 주간 상태를 초기화합니다.
    func startNewConquestPeriod() {
        // 직전 주차 스냅샷 저장
        finalizeCurrentWeekSnapshot()

        // 새 기간 생성
        let today = Date()
        currentPeriod = ConquestPeriod(startDate: today)

        // 주간 상태 초기화
        resetDailyStatus()
        userStatus.userWeekScore = 0
    }

    /// 직전 주차의 점령 기록 스냅샷을 생성하여 사용자 이력에 저장합니다.
    ///
    /// - Parameter distanceKm: 해당 주차 동안 이동한 거리(km)
    private func finalizeCurrentWeekSnapshot(distanceKm: Double? = nil) {
        let snapshot = RankRecord(
            periodID: currentPeriod.id,
            startDate: currentPeriod.startDate,
            endDate: currentPeriod.endDate,
            rank: userStatus.rank,
            weekScore: userStatus.userWeekScore,
            distanceKm: distanceKm
        )
        UserManager.shared.appendRankRecord(snapshot)
    }
}
