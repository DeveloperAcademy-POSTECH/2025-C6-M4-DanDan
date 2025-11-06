//
//  MyPageViewModel.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

import SwiftUI
import UIKit
import CoreLocation


@MainActor
class MyPageViewModel: ObservableObject {
    private let navigationManager = NavigationManager.shared
    private let userService: UserServiceProtocol = UserService()
    
    // MARK: - User State
    @Published var userInfo: UserInfo
    @Published var userStatus: UserStatus
    @Published var currentPeriod: ConquestPeriod? = nil
    
    // MARK: - Derived Profile Values
    var profileImage: Image {
        if let data = userInfo.userImage.last, let ui = UIImage(data: data) {
            return Image(uiImage: ui)
        }
        return Image("testImage")
    }
    
    var displayName: String { userInfo.userName }
    var winCount: Int {
        let now = Date()
        // 완료된 주차 중, 스냅샷 시점의 내 팀이 그 주의 우승 팀이었던 횟수
        return userInfo.rankHistory.filter { record in
            guard let myTeam = record.teamAtPeriod, let winning = record.winningTeam else { return false }
            return record.endDate < now && myTeam == winning
        }.count
    }
    var totalScore: Int { userInfo.userTotalScore }
    
    // FIXME: - 임시 계산 로직 (추후 폴리라인 세분화 및 거리 계산 방식 개선 예정)
    // TODO: - 완료된 구역들의 폴리라인 길이를 합산하여 총 거리를 계산 (추후 상세화 예정)
    var totalDistanceMeters: Double {
            // 완료된 Zone ID 수집
            let completedZoneIds: Set<Int> = Set(
                userStatus.zoneCheckedStatus.compactMap { (key, value) in value ? key : nil }
            )
            // 만약 통과한 Zone이 하나도 없으면 계산할 필요 없이 거리 0 반환
            guard !completedZoneIds.isEmpty else { return 0 }
            
            return zones
                    // 완료된 Zone만 필터링
                .filter { completedZoneIds.contains($0.zoneId) }
                // 각 Zone별 거리 계산
                .map { zone in
                    let coords = zone.coordinates
                    guard coords.count >= 2 else { return 0.0 }
                    var sum: Double = 0
                    for i in 1..<coords.count {
                        let a = CLLocation(latitude: coords[i-1].latitude, longitude: coords[i-1].longitude)
                        let b = CLLocation(latitude: coords[i].latitude, longitude: coords[i].longitude)
                        sum += a.distance(from: b)
                    }
                    return sum
                }
                // 모든 Zone의 거리 합산
                .reduce(0, +)
        }
    
    var totalDistanceKmText: String {
        let km = totalDistanceMeters / 1000.0
        return String(format: "%.1f", km)
    }
    
    // MARK: - Weekly Activity Derived Values
    var currentWeekText: String {
        var cal = Calendar(identifier: .iso8601)
        cal.locale = Locale(identifier: "ko_KR")
        cal.firstWeekday = 2 // 월요일 시작
        let baseDate = currentPeriod?.startDate ?? Date()
        let comps = cal.dateComponents([.year, .month, .weekOfMonth], from: baseDate)
        guard let year = comps.year, let month = comps.month, let week = comps.weekOfMonth else { return "현재: -" }
        return "현재: \(year)년 \(month)월 \(week)주차"
    }
    
    var weekDistanceKmText: String {
        // 현 단계에서는 누적 완료 구역 거리를 주간 카드에도 동일 반영
        return totalDistanceKmText
    }
    
    var weekScore: Int { userStatus.userWeekScore }
    var teamRank: Int { userStatus.rank }
    
    // MARK: - Init
    /// 사용자 정보 및 상태 매니저를 초기화합니다.
    /// - Parameters:
    ///   - userInfo: 사용자 기본 정보(`UserInfo`)
    ///   - userStatus: 사용자 활동 상태(`UserStatus`)
    init(
        userInfo: UserInfo = UserInfo(
            id: UUID(),
            userName: "김소원멍청이",
            userVictoryCnt: 7,
            userTotalScore: 105,
            userImage: [],
            rankHistory: []
        ),
        userStatus: UserStatus = UserStatus()
    ) {
        self.userInfo = userInfo
        self.userStatus = userStatus
    }

    func tapSeasonHistoryButton() {
        navigationManager.navigate(to: .seasonHistory)
    }

    func tapProfileEditButton() {
        navigationManager.navigate(to: .profileEdit)
    }

    // MARK: - Networking
    func load() async {
        do {
            let resp = try await userService.fetchMyPage()
            // Map to local models used by the view
            userInfo.userName = resp.data.user.userName
            userInfo.userVictoryCnt = resp.data.user.userVictoryCnt
            userInfo.userTotalScore = resp.data.user.userTotalScore
            userStatus.userWeekScore = resp.data.currentWeekActivity.userWeekScore
            userStatus.rank = resp.data.currentWeekActivity.ranking
            // 프로필 이미지 URL이 있으면 다운로드해 로컬 캐시에 반영
            if let urlString = resp.data.user.profileUrl, let url = URL(string: urlString) {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if !data.isEmpty {
                        userInfo.userImage = [data]
                    }
                } catch {
                    print("⚠️ Failed to load profile image:", error)
                }
            }
            // currentPeriod start date
            if let start = ISO8601DateFormatter().date(from: resp.data.currentWeekActivity.startDate) {
                self.currentPeriod = ConquestPeriod(startDate: start)
            }
        } catch {
            print("🚨 MyPage load failed:", error)
        }
    }
}
