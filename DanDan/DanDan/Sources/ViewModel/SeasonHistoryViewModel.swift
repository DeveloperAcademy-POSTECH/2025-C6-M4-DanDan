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
    @Published private(set) var hasCurrentWeek: Bool = false

    private var timerCancellable: AnyCancellable?
    private let calendar: Calendar
    private let dayFormatter: DateFormatter

    // 서버에서 내려주는 현재 주간 ConquestPeriod (월~일)
    private(set) var period: ConquestPeriod?

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

        // 서버 수신 전 초기 표시값
        self.weekLabel = ""
        self.weekRange = ""
        self.progress = 0
        self.remainingText = ""
        self.statusText = ""
        self.currentDistanceKm = 0
        self.currentWeekScore = 0
        self.currentTeamRank = 0
        self.period = nil

        // 분 단위 갱신
        if autoRefresh {
            timerCancellable = Timer
                .publish(every: 60, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] now in
                    guard let self = self, let period = self.period else { return }
                    let endOfWeek = period.endDate.endOfDay(calendar: self.calendar)
                    self.progress = Self.progress(now: now, in: period, calendar: self.calendar)
                    self.remainingText = Self.remainingText(now: now, to: endOfWeek, calendar: self.calendar)
                    self.statusText = self.progress >= 1.0 ? "완료" : "진행 중"
                }
        }
    }

    func load(page: Int = 1, size: Int = 5) async {
        do {
            let data = try await SeasonHistoryService.shared.fetchUserHistoryAsync(page: page, size: size)

            if let cw = data.currentWeek {
                self.hasCurrentWeek = true

                if let s = SeasonHistoryDateParser.parse(cw.startDate),
                   let _ = SeasonHistoryDateParser.parse(cw.endDate) {
                    let period = ConquestPeriod(startDate: s, durationInDays: 6, weekIndex: cw.weekIndex)
                    self.period = period

                    self.weekLabel = Self.makeWeekLabel(for: s, weekIndex: cw.weekIndex, calendar: self.calendar)
                    let monday = self.calendar.dateInterval(of: .weekOfYear, for: s)!.start
                    let sunday = self.calendar.date(byAdding: .day, value: 6, to: monday)!
                    self.weekRange = "\(self.dayFormatter.string(from: monday)) ~ \(self.dayFormatter.string(from: sunday))"
                    self.progress = Self.progress(now: Date(), in: period, calendar: self.calendar)
                    self.remainingText = Self.remainingText(now: Date(), to: sunday.endOfDay(calendar: self.calendar), calendar: self.calendar)
                    self.statusText = self.progress >= 1.0 ? "완료" : "진행 중"
                }

                self.currentWeekScore = cw.userWeekScore
                self.currentTeamRank = cw.ranking
                self.currentDistanceKm = cw.distanceKm ?? 0
            } else {
                self.hasCurrentWeek = false
            }

            let mapped: [RankRecord] = data.pastWeeks.data.map { item in
                let start = item.startDate.flatMap { SeasonHistoryDateParser.parse($0) } ?? Date()
                let endCandidate = item.endDate.flatMap { SeasonHistoryDateParser.parse($0) }
                let end = endCandidate ?? self.calendar.date(byAdding: .day, value: 6, to: start) ?? start
                return RankRecord(
                    periodID: UUID(),
                    startDate: start,
                    endDate: end,
                    rank: item.rank,
                    weekScore: item.weekScore,
                    distanceKm: item.distanceKm
                )
            }
            self.completed = mapped.sorted { $0.startDate > $1.startDate }
        } catch {
            print("❌ SeasonHistory load failed: \(error)")
            self.hasCurrentWeek = false
            self.completed = []
            self.weekLabel = ""
            self.weekRange = ""
            self.statusText = ""
            self.progress = 0
            self.remainingText = ""
            self.currentDistanceKm = 0
            self.currentWeekScore = 0
            self.currentTeamRank = 0
        }
    }

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

    /// 서버에서 내려준 주차 인덱스를 그대로 사용하여 라벨을 구성합니다.
    private static func makeWeekLabel(for monday: Date, weekIndex: Int, calendar: Calendar) -> String {
        let y = calendar.component(.year, from: monday)
        let m = calendar.component(.month, from: monday)
        return "\(y)년 \(m)월 \(weekIndex)주차"
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

// MARK: - Date Parsing Helper (moved from DTO)
enum SeasonHistoryDateParser {
    /// 서버 날짜 문자열을 Date로 파싱 (여러 포맷 지원)
    static func parse(_ value: String) -> Date? {
        // 1) ISO8601 우선
        if let iso = ISO8601DateFormatter().date(from: value) {
            return iso
        }
        // 2) yyyy-MM-dd 및 기타 포맷
        let fmts = [
            "yyyy-MM-dd",
            "yyyy.MM.dd",
            "yyyy-MM-dd'T'HH:mm:ssXXXXX",
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        ]
        for f in fmts {
            let df = DateFormatter()
            df.locale = Locale(identifier: "ko_KR")
            df.timeZone = TimeZone(identifier: "Asia/Seoul")
            df.dateFormat = f
            if let d = df.date(from: value) {
                return d
            }
        }
        return nil
    }
}

private extension Date {
    func endOfDay(calendar: Calendar) -> Date {
        let start = calendar.startOfDay(for: self)
        return calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start)!
    }
}

