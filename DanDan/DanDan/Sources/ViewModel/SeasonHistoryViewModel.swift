//
//  SeasonHistoryViewModel.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

import Foundation
import Combine

struct WeekDisplay {
    let label: String      // 예: "2025년 10월 2주차"
    let range: String      // 예: "2025.10.06 ~ 2025.10.12"
}

enum SeasonStatus {
    case inProgress, completed
    var title: String {
        switch self {
        case .inProgress: return "진행 중"
        case .completed:  return "완료"
        }
    }
}

struct SeasonStats {
    let flags: Int                 // (선택) 깃발 수 표시용
    let distanceKm: Double
    let score: Int                 // 주간 점수
    let teamRank: Int              // 팀 내 순위 (1부터 시작)
}

/// 과거 주차 표시용 DTO
struct CompletedSeasonItem: Identifiable {
    var id: UUID = UUID()
    let week: WeekDisplay
    let period: ConquestPeriod
    let stats: SeasonStats
}

@MainActor
final class SeasonHistoryViewModel: ObservableObject {
    @Published private(set) var week: WeekDisplay
    @Published private(set) var status: SeasonStatus
    @Published private(set) var progress: Double        // 0.0 ~ 1.0
    @Published private(set) var remainingText: String
    @Published private(set) var stats: SeasonStats
    @Published private(set) var completedWeeks: [CompletedSeasonItem] = []

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
        let initialWeek = WeekDisplay(
            label: Self.weekOfMonthLabel(for: monday, calendar: cal),
            range: "\(df.string(from: monday)) ~ \(df.string(from: sunday))"
        )
        let initialProgress = Self.progress(now: now, in: period, calendar: cal)
        let initialRemaining = Self.remainingText(now: now, to: sunday.endOfDay(calendar: cal), calendar: cal)
        let initialStatus: SeasonStatus = initialProgress >= 1.0 ? .completed : .inProgress

        self.week = initialWeek
        self.progress = initialProgress
        self.remainingText = initialRemaining
        self.status = initialStatus

        // TODO: 실제 통계 연동 지점
        self.stats = SeasonStats(flags: 3, distanceKm: 5.2, score: 1200, teamRank: 3)

        // 과거 주차 목록 구성 (가입 시점부터, 이번 주 이전까지)
        let signupDate = Self.fetchSignupDate() // TODO: 실제 저장소 연동
        self.completedWeeks = Self.buildCompletedWeeks(
            from: signupDate,
            until: monday.addingTimeInterval(-1), // 이번 주 시작 전날까지
            calendar: cal,
            dayFormatter: df
        )

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

        week = WeekDisplay(
            label: Self.weekOfMonthLabel(for: monday, calendar: calendar),
            range: "\(dayFormatter.string(from: monday)) ~ \(dayFormatter.string(from: sunday))"
        )
        progress = Self.progress(now: now, in: period, calendar: calendar)
        remainingText = Self.remainingText(now: now, to: sunday.endOfDay(calendar: calendar), calendar: calendar)
        status = progress >= 1.0 ? .completed : .inProgress

        // stats = fetchStats(for: period)
    }

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

    /// 가입 시점부터 특정 날짜까지의 '완료된 주' 목록을 생성
    private static func buildCompletedWeeks(
        from signupDate: Date,
        until endDate: Date,
        calendar: Calendar,
        dayFormatter: DateFormatter
    ) -> [CompletedSeasonItem] {
        var items: [CompletedSeasonItem] = []

        // 시작 주의 월요일
        let startWeekMonday = calendar.dateInterval(of: .weekOfYear, for: signupDate)!.start

        // 종료 주의 일요일(포함)
        let endWeekSunday = calendar.dateInterval(of: .weekOfYear, for: endDate)!.start
        // 주 단위로 순회
        var curMonday = startWeekMonday
        while curMonday <= endWeekSunday {
            let curSunday = calendar.date(byAdding: .day, value: 6, to: curMonday)!
            // '이번 주'는 제외 (완료 주만)
            if curSunday < calendar.dateInterval(of: .weekOfYear, for: Date())!.start {
                let weekOfMonth = calendar.component(.weekOfMonth, from: curMonday)
                let period = ConquestPeriod(startDate: curMonday, durationInDays: 6, weekIndex: weekOfMonth)
                let label = weekOfMonthLabel(for: curMonday, calendar: calendar)
                let range = "\(dayFormatter.string(from: curMonday)) ~ \(dayFormatter.string(from: curSunday))"

                // TODO: 실제 통계 가져오기
                let stats = SeasonStats(
                    flags: Int.random(in: 0...5),
                    distanceKm: Double.random(in: 3...15),
                    score: Int.random(in: 200...2500),
                    teamRank: Int.random(in: 1...15)
                )

                items.append(CompletedSeasonItem(
                    week: WeekDisplay(label: label, range: range),
                    period: period,
                    stats: stats
                ))
            }
            // 다음 주
            guard let next = calendar.date(byAdding: .weekOfYear, value: 1, to: curMonday) else { break }
            curMonday = next
        }
        // 최신 주가 위로 오도록 내림차순 정렬
        return items.sorted { $0.period.startDate > $1.period.startDate }
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
        let comps = calendar.dateComponents([.day, .hour], from: now, to: end)
        let d = comps.day ?? 0
        let h = comps.hour ?? 0
        if d > 0 { return "\(d)일 \(h)시간 남음" }
        return "\(max(0, h))시간 남음"
    }
}

private extension Date {
    func endOfDay(calendar: Calendar) -> Date {
        let start = calendar.startOfDay(for: self)
        return calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start)!
    }
}
