//
//  ConquestPeriod+.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

import Foundation

extension ConquestPeriod {
    func isWithinPeriod(date: Date = Date()) -> Bool {
        (startDate...endDate).contains(date)
    }

    var hasEnded: Bool {
        Date() > endDate
    }

    func daysLeft(from date: Date = Date()) -> Int {
        let remaining = Calendar.current.dateComponents(
            [.day],
            from: date,
            to: endDate
        ).day ?? 0
        
        return max(0, remaining)
    }
}
