//
//  SeasonHistoryViewModel.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

import Foundation
import Combine

@MainActor
final class SeasonHistoryViewModel: ObservableObject {
    @Published private(set) var weekLabel: String
    @Published private(set) var weekRange: String
    @Published private(set) var statusText: String
    @Published private(set) var progress: Double        // 0.0 ~ 1.0
    @Published private(set) var remainingText: String
    @Published private(set) var currentDistanceKm: Double
    @Published private(set) var currentWeekScore: Int
    @Published private(set) var currentTeamRank: Int
    @Published private(set) var completed: [RankRecord] = []

    private var timerCancellable: AnyCancellable?
    private let calendar: Calendar
    private let dayFormatter: DateFormatter

    // 현재 주간 ConquestPeriod (월~일)
    private(set) var period: ConquestPeriod

    init(now: Date = Date(), autoRefresh: Bool = true) {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "ko_KR")
        cal.timeZone = TimeZone(identifier: "Asia/Seoul")!
        cal.firstWeekday = 2 // Monday
        self.calendar = cal

        let df = DateFormatter()
        df.locale = cal.locale
        df.timeZone = cal.timeZone
        df.dateFormat = "yyyy.MM.dd"
        self.dayFormatter = df

        // 이번 주(월~일) 경계 계산
        let (monday, sunday) = Self.currentWeekBounds(from: now, calendar: cal)
        let weekOfMonth = cal.component(.weekOfMonth, from: monday)
        // ConquestPeriod는 종료일 산정이 +durationInDays 이므로 월→일 포함을 위해 6일 사용
        self.period = ConquestPeriod(startDate: monday, durationInDays: 6, weekIndex: weekOfMonth)

        // 초기 표시값 세팅 (로컬로 계산 후 한 번에 할당하여 self 접근을 늦춤)
        let initialWeekLabel = Self.weekOfMonthLabel(for: monday, calendar: cal)
        let initialWeekRange = "\(df.string(from: monday)) ~ \(df.string(from: sunday))"
        let initialProgress = Self.progress(now: now, in: period, calendar: cal)
        let initialRemaining = Self.remainingText(now: now, to: sunday.endOfDay(calendar: cal), calendar: cal)
        let initialStatusText: String = initialProgress >= 1.0 ? "완료" : "진행 중"

        self.weekLabel = initialWeekLabel
        self.weekRange = initialWeekRange
        self.progress = initialProgress
        self.remainingText = initialRemaining
        self.statusText = initialStatusText

        // 현재 주: UserStatus 기반으로 점수/랭킹 반영
        let currentStatus = StatusManager.shared.userStatus
        self.currentDistanceKm = 0 // TODO: 주간 거리 집계 연동 시 교체
        self.currentWeekScore = currentStatus.userWeekScore
        self.currentTeamRank = currentStatus.rank

        // 과거 주차 RankRecord 스냅샷 기반 목록 구성 (이번 주 제외)
        self.completed = Self.fetchCompletedRankRecords(before: monday, calendar: cal)

        // 분 단위 갱신
        if autoRefresh {
            timerCancellable = Timer
                .publish(every: 60, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] now in
                    self?.refresh(now: now)
                }
        }
    }

    func refresh(now: Date = Date()) {
        let (monday, sunday) = Self.currentWeekBounds(from: now, calendar: calendar)
        if calendar.isDate(monday, inSameDayAs: period.startDate) == false {
            // 새 주차로 넘어간 경우 period 갱신
            let weekOfMonth = calendar.component(.weekOfMonth, from: monday)
            period = ConquestPeriod(startDate: monday, durationInDays: 6, weekIndex: weekOfMonth)
        }

        weekLabel = Self.weekOfMonthLabel(for: monday, calendar: calendar)
        weekRange = "\(dayFormatter.string(from: monday)) ~ \(dayFormatter.string(from: sunday))"
        progress = Self.progress(now: now, in: period, calendar: calendar)
        remainingText = Self.remainingText(now: now, to: sunday.endOfDay(calendar: calendar), calendar: calendar)
        statusText = progress >= 1.0 ? "완료" : "진행 중"

        // 현재 주 점수/랭킹 갱신
        let currentStatus = StatusManager.shared.userStatus
        currentWeekScore = currentStatus.userWeekScore
        currentTeamRank = currentStatus.rank
    }

#if DEBUG
    /// 프리뷰/디버그 전용: 과거 RankRecord 목록을 주입합니다.
    func debugSetCompleted(_ records: [RankRecord]) {
        self.completed = records
    }
#endif

    /// 실제 앱에서는 Keychain/UserDefaults/서버에서 가입 시점을 가져온다.
    private static func fetchSignupDate() -> Date {
        // 임시: 프리뷰/로컬 개발용으로 6주 전 월요일을 반환
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "ko_KR")
        cal.timeZone = TimeZone(identifier: "Asia/Seoul")!
        cal.firstWeekday = 2
        let now = Date()
        let sixWeeksAgo = cal.date(byAdding: .weekOfYear, value: -6, to: now)!
        let startOfWeek = cal.dateInterval(of: .weekOfYear, for: sixWeeksAgo)!.start
        return startOfWeek
    }

    /// 이번 주 시작 이전의 RankRecord 스냅샷을 가져옵니다.
    private static func fetchCompletedRankRecords(before thisMonday: Date, calendar: Calendar) -> [RankRecord] {
        let all = UserManager.shared.userInfo.rankHistory
        let filtered = all.filter { $0.endDate < thisMonday }
        // 최신 주가 위로 오도록 내림차순 정렬
        return filtered.sorted { $0.startDate > $1.startDate }
    }

    // MARK: - Completed Accessors
    var completedCount: Int { completed.count }
    func completedId(at index: Int) -> UUID { completed[index].id }
    func completedWeekLabel(at index: Int) -> String {
        let rr = completed[index]
        let y = calendar.component(.year, from: rr.startDate)
        let m = calendar.component(.month, from: rr.startDate)
        let w = calendar.component(.weekOfMonth, from: rr.startDate)
        return "\(y)년 \(m)월 \(w)주차"
    }
    func completedWeekRange(at index: Int) -> String {
        let rr = completed[index]
        let monday = calendar.dateInterval(of: .weekOfYear, for: rr.startDate)!.start
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday)!
        return "\(dayFormatter.string(from: monday)) ~ \(dayFormatter.string(from: sunday))"
    }
    func completedDistanceKm(at index: Int) -> Double { completed[index].distanceKm ?? 0 }
    func completedScore(at index: Int) -> Int { completed[index].weekScore }
    func completedTeamRank(at index: Int) -> Int { completed[index].rank }

    // Record 기반 접근자 (카드에 레코드와 함께 문자열 내려주기용)
    func completedWeekLabel(for record: RankRecord) -> String {
        let y = calendar.component(.year, from: record.startDate)
        let m = calendar.component(.month, from: record.startDate)
        let w = calendar.component(.weekOfMonth, from: record.startDate)
        return "\(y)년 \(m)월 \(w)주차"
    }
    func completedWeekRange(for record: RankRecord) -> String {
        let monday = calendar.dateInterval(of: .weekOfYear, for: record.startDate)!.start
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday)!
        return "\(dayFormatter.string(from: monday)) ~ \(dayFormatter.string(from: sunday))"
    }

    // MARK: - Helpers

    private static func currentWeekBounds(from date: Date, calendar: Calendar) -> (monday: Date, sunday: Date) {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)!.start
        let monday = startOfWeek // firstWeekday = 2 (Mon)
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday)!
        return (monday, sunday)
    }

    private static func weekOfMonthLabel(for monday: Date, calendar: Calendar) -> String {
        let y = calendar.component(.year, from: monday)
        let m = calendar.component(.month, from: monday)
        let w = calendar.component(.weekOfMonth, from: monday)
        return "\(y)년 \(m)월 \(w)주차"
    }

    private static func progress(now: Date, in period: ConquestPeriod, calendar: Calendar) -> Double {
        let start = calendar.startOfDay(for: period.startDate)
        let end = period.endDate.endOfDay(calendar: calendar)
        guard end > start else { return 1 }
        let total = end.timeIntervalSince(start)
        let done = now.timeIntervalSince(start)
        return max(0, min(1, done / total))
    }

    private static func remainingText(now: Date, to end: Date, calendar: Calendar) -> String {
        if now >= end { return "종료" }
        let comps = calendar.dateComponents([.day, .hour, .minute], from: now, to: end)
        let d = comps.day ?? 0
        let h = comps.hour ?? 0
        let m = comps.minute ?? 0
        if d > 0 { return "\(d)일 \(h)시간 남음" }
        if h > 0 { return "\(h)시간 남음" }
        if m > 0 { return "\(m)분 남음" }
        return "종료"
    }
}

private extension Date {
    func endOfDay(calendar: Calendar) -> Date {
        let start = calendar.startOfDay(for: self)
        return calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start)!
    }
}
