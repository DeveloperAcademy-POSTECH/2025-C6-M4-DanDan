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
        ) else {
            fatalError("endDate 계산 실패")
        }
        
        self.endDate = calculatedEndDate
    }
    
    func isWithinPeriod(date: Date = Date()) -> Bool {
        (startDate...endDate).contains(date)
    }
}
