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
    
    // MARK: - User State
    @Published var userInfo: UserInfo
    @Published var userStatus: UserStatus
    @Published var currentPeriod: ConquestPeriod? = nil
    
    // MARK: - Init
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
    
    // MARK: - Derived Profile Values
    var profileImage: Image {
        if let data = userInfo.userImage.last, let ui = UIImage(data: data) {
            return Image(uiImage: ui)
        }
        return Image("testImage")
    }
    
    var displayName: String { userInfo.userName }
    var winCount: Int { userInfo.userVictoryCnt }
    var totalScore: Int { userInfo.userTotalScore }
    
    var totalDistanceMeters: Double {
        // 완료된 구역들의 폴리라인 길이를 합산하여 총 거리를 계산
        let completedZoneIds: Set<Int> = Set(
            userStatus.zoneCheckedStatus.compactMap { (key, value) in value ? key : nil }
        )
        guard !completedZoneIds.isEmpty else { return 0 }
        
        return zones
            .filter { completedZoneIds.contains($0.zoneId) }
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

    func tapSeasonHistoryButton() {
        navigationManager.navigate(to: .seasonHistory)
    }

    func tapProfileEditButton() {
        navigationManager.navigate(to: .profileEdit)
    }
}
