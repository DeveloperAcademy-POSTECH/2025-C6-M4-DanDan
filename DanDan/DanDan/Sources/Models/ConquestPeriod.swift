//
//  ConquestPeriod.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

import Foundation

struct ConquestPeriod: Identifiable, Codable {
    var id: UUID
    let startDate: Date
    let endDate: Date
    var weekIndex: Int // 주차 표시
    var winningTeam: String
    
    // TODO: - '점령전 기간 재설정' 로직 구현 후 이사 예정
    init(startDate: Date, durationInDays: Int = 7, weekIndex: Int = 1, winningTeam: String = "") {
        self.id = UUID()
        self.startDate = startDate
        self.weekIndex = weekIndex
        self.winningTeam = winningTeam

        guard let calculatedEndDate = Calendar.current.date(
                byAdding: .day,
                value: durationInDays,
                to: startDate
            )
        else {
            fatalError("ConquestPeriod 초기화 실패: startDate로부터 endDate 계산 불가")
        }

        self.endDate = calculatedEndDate
    }
}
