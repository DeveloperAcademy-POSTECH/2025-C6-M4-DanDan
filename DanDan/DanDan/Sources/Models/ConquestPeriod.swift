//
//  ConquestPeriod.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

import Foundation

struct ConquestPeriod {
    let startDate: Date
    let endDate: Date

    init(startDate: Date, durationInDays: Int = 7) {
        self.startDate = startDate

        guard let calculatedEndDate = Calendar.current.date(
                byAdding: .day,
                value: durationInDays,
                to: startDate
            )
        else {
            fatalError("endDate 계산 실패")
        }

        self.endDate = calculatedEndDate
    }

    func isWithinPeriod(date: Date = Date()) -> Bool {
        (startDate...endDate).contains(date)
    }

    var hasEended: Bool {
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
