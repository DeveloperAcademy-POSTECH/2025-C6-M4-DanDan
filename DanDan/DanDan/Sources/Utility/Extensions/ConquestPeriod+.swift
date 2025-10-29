//
//  ConquestPeriod+.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

import Foundation

extension ConquestPeriod {
    
    /// 주어진 날짜가 현재 점령 기간내에 포함되느지 여부를 반환합니다.
    ///  - Parameter date: 확인할 날짜 (기본값: 오늘)
    ///  - Returns: 점령 기간 내 포함 여부 (true/false)
    func isWithinPeriod(date: Date = Date()) -> Bool {
        (startDate...endDate).contains(date)
    }

    /// 현재 날짜 기준으로 점령 기간이 종료되었는지 여부를 반환합니다.
    var hasEnded: Bool {
        Date() > endDate
    }

    /// 주어진 날짜 시준으로 점령 기간의 남은 일수를 계산합니다.
    ///  - Parameter date: 기준 날짜 (기본값: 오늘)
    ///  - Returns: 남은 일 수 (0 이하일 경우 0 반환)
    func daysLeft(from date: Date = Date()) -> Int {
        let remaining = Calendar.current.dateComponents(
            [.day],
            from: date,
            to: endDate
        ).day ?? 0
        
        return max(0, remaining)
    }
}
