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
    var teamRegionName: String {
        switch userStatus.userTeam.lowercased() {
        case "blue":
            return "북구"
        case "yellow":
            return "남구"
        default:
            return userStatus.userTeam
        }
    }

    var currentWeekText: String {
        guard let period = currentPeriod else { return "-" }
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        let comps = calendar.dateComponents([.year, .month], from: period.startDate)
        let year = comps.year ?? 0
        let month = comps.month ?? 0
        return "\(year)년 \(month)월 \(period.weekIndex)주차"
    }

    // MARK: - Distance (API 기반)
    @Published var totalDistanceKm: Double = 0
    /// 총 주간 이동거리 텍스트 (정수, km) - API 응답 사용
    var totalDistanceKmText: String {
        return String(format: "%.1f", totalDistanceKm)
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
            totalDistanceKm = resp.data.currentWeekActivity.totalDistanceKm

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

