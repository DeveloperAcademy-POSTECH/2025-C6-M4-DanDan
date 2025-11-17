//
//  MyPageViewModel.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

import CoreLocation
import SwiftUI
import UIKit

@MainActor
class MyPageViewModel: ObservableObject {
    private let navigationManager = NavigationManager.shared
    private let myPageService: MyPageServiceProtocol = MyPageService()

    // MARK: - User State

    @Published var userInfo: UserInfo
    @Published var userStatus: UserStatus
    @Published var currentPeriod: ConquestPeriod? = nil

    var profileImage: Image {
        if let data = userInfo.userImage.last, let ui = UIImage(data: data) {
            return Image(uiImage: ui)
        }
        return Image("default_avatar")
    }

    var displayName: String { userInfo.userName }
    var winCount: Int { userInfo.userVictoryCnt }
    var totalScore: Int { userInfo.userTotalScore }
    var weekScore: Int { userStatus.userWeekScore }
    var teamRank: Int { userStatus.rank }
    var teamName: String { userStatus.userTeam }

    var currentWeekText: String {
        guard let period = currentPeriod else { return "-" }
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        let comps = calendar.dateComponents([.year, .month], from: period.startDate)
        let year = comps.year ?? 0
        let month = comps.month ?? 0
        return "\(year)년 \(month)월 \(period.weekIndex)주차"
    }

    // FIXME: - 임시 계산 로직 (추후 폴리라인 세분화 및 거리 계산 방식 개선 예정)
    // TODO: - 완료된 구역들의 폴리라인 길이를 합산하여 총 거리를 계산 (추후 상세화 예정)
    var weekDistanceKmText: String {
        // 현 단계에서는 누적 완료 구역 거리를 주간 카드에도 동일 반영
        return totalDistanceKmText
    }

    /// 주간 거리의 정수부 텍스트 (km)
    var weekDistanceKmIntText: String {
        let km = totalDistanceMeters / 1000.0
        return String(Int(km))
    }

    var totalDistanceMeters: Double {
        // 완료된 Zone ID 수집
        let completedZoneIds: Set<Int> = Set(
            userStatus.zoneCheckedStatus.compactMap { key, value in value ? key : nil }
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
                for i in 1 ..< coords.count {
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

    // MARK: - Init

    /// 사용자 정보 및 상태 매니저를 초기화합니다.
    /// - Parameters:
    ///   - userInfo: 사용자 기본 정보(`UserInfo`)
    ///   - userStatus: 사용자 활동 상태(`UserStatus`)
    init(
        userInfo: UserInfo = UserInfo(
            id: UUID(),
            userName: "",
            userVictoryCnt: 0,
            userTotalScore: 0,
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
    
    // 서버에서 내려오는 날짜 문자열을 다양한 포맷으로 안전하게 파싱
    private func parseServerDate(_ s: String) -> Date? {
        // ISO8601 + fractional seconds
        let iso1 = ISO8601DateFormatter()
        iso1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso1.date(from: s) { return d }
        
        // 일반 ISO8601
        let iso2 = ISO8601DateFormatter()
        iso2.formatOptions = [.withInternetDateTime]
        if let d = iso2.date(from: s) { return d }
        
        // 자주 쓰는 포맷들 (RFC3339/날짜 전용)
        let patterns = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
            "yyyy-MM-dd'T'HH:mm:ssXXXXX",
            "yyyy-MM-dd"
        ]
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        for p in patterns {
            df.dateFormat = p
            if let d = df.date(from: s) { return d }
        }
        return nil
    }

    func load() async {
        do {
            let resp = try await myPageService.fetchMyPage()

            userInfo.userName = resp.data.user.userName
            userInfo.userVictoryCnt = resp.data.user.userVictoryCnt
            userInfo.userTotalScore = resp.data.user.userTotalScore
            userStatus.userTeam = resp.data.user.userTeam
            userStatus.userWeekScore = resp.data.currentWeekActivity.userWeekScore
            userStatus.rank = resp.data.currentWeekActivity.ranking

            // 프로필 이미지 처리: URL이 없으면 로컬 캐시 제거, 있으면 다운로드하여 갱신
            if let urlString = resp.data.user.profileUrl, let url = URL(string: urlString) {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if !data.isEmpty {
                        userInfo.userImage = [data]
                    } else {
                        userInfo.userImage = []
                    }
                } catch {
                    print("⚠️ Failed to load profile image:", error)
                    userInfo.userImage = []
                }
            } else {
                userInfo.userImage = []
            }

            let s = resp.data.currentWeekActivity.startDate
            let e = resp.data.currentWeekActivity.endDate
            if let start = parseServerDate(s),
               let end = parseServerDate(e) {
                let durationDays = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 7
                currentPeriod = ConquestPeriod(
                    startDate: start,
                    durationInDays: durationDays,
                    weekIndex: resp.data.currentWeekActivity.weekIndex
                )
            }
        } catch {
            print("🚨 MyPage load failed:", error)
        }
    }
}
