//
//  ConquestPeriod+.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

import Foundation

extension ConquestPeriod {

    /// 주어진 날짜가 현재 점령 기간내에 포함되는지 여부를 반환합니다.
    ///  - Parameter date: 확인할 날짜 (기본값: 오늘)
    ///  - Returns: 점령 기간 내 포함 여부 (true/false)
    func isWithinPeriod(date: Date = Date()) -> Bool {
        (startDate...endDate).contains(date)
    }

    /// 현재 날짜 기준으로 점령 기간이 종료되었는지 여부를 반환합니다.
    var hasEnded: Bool {
        Date() > endDate
    }

    /// 주어진 날짜 시점으로 점령 기간의 남은 일수를 계산합니다.
    ///  - Parameter date: 기준 날짜 (기본값: 오늘)
    ///  - Returns: 남은 일 수 (0 이하일 경우 0 반환)
    func daysLeft(from date: Date = Date()) -> Int {
        let remaining =
            Calendar.current.dateComponents(
                [.day],
                from: date,
                to: endDate
            ).day ?? 0

        return max(0, remaining)
    }

    /// 문자열로 받은 종료 날짜를 기반으로 남은 D-Day(남은 일수)를 계산합니다.
    /// - Parameter endDateString: ISO8601 형식의 종료 날짜 문자열
    /// - Returns: 오늘 기준 남은 일수 (0 이하일 경우 0 반환)
    static func from(endDateString: String) -> Int {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // 서버는 UTC
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // 밀리초 포함 지원
        
        guard let endDateUTC = isoFormatter.date(from: endDateString) else {
            return 0
        }

        // 한국 시간(KST) 변환
        let endDateKST = endDateUTC.addingTimeInterval(9 * 60 * 60)

        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: endDateKST).day ?? 0
        
        return max(0, remaining)
    }
}
