//
//  ConquestPeriodTests.swift
//  DanDan
//
//  Created by Jay on 10/26/25.
//

import XCTest
import os
@testable import DanDan

final class ConquestPeriodTests: XCTestCase {
    private let logger = Logger(subsystem: "com.dandan.tests", category: "ConquestPeriod")

    func test_endDateCalculation() {
        let start = Date(timeIntervalSince1970: 0)
        let period = ConquestPeriod(startDate: start)
        let expectedEnd = Calendar.current.date(byAdding: .day, value: 7, to: start)
        
        logger.info("🧪 endDateCalculation → start: \(start, privacy: .public), expectedEnd: \(expectedEnd ?? Date(), privacy: .public), actualEnd: \(period.endDate, privacy: .public)")
        
        XCTAssertEqual(period.endDate, expectedEnd)
    }

    func test_isWithinPeriod() {
        let start = Date()
        let period = ConquestPeriod(startDate: start)
        
        let midDate = Calendar.current.date(byAdding: .day, value: 3, to: start)!
        let afterDate = Calendar.current.date(byAdding: .day, value: 8, to: start)!
        
        logger.info("🧪 isWithinPeriod")
        logger.info(" - start: \(period.isWithinPeriod(date: start), privacy: .public)")
        logger.info(" - mid (3일 후): \(period.isWithinPeriod(date: midDate), privacy: .public)")
        logger.info(" - end: \(period.isWithinPeriod(date: period.endDate), privacy: .public)")
        logger.info(" - after (8일 후): \(period.isWithinPeriod(date: afterDate), privacy: .public)")
        
        XCTAssertTrue(period.isWithinPeriod(date: start))
        XCTAssertTrue(period.isWithinPeriod(date: midDate))
        XCTAssertTrue(period.isWithinPeriod(date: period.endDate))
        XCTAssertFalse(period.isWithinPeriod(date: afterDate))
    }

    func test_hasEnded() {
        let start = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let period = ConquestPeriod(startDate: start)
        
        logger.info("🧪 hasEnded → start: \(start, privacy: .public), now: \(Date(), privacy: .public), hasEnded: \(period.hasEnded, privacy: .public)")
        
        XCTAssertTrue(period.hasEnded)
    }

    func test_daysLeft() {
        let start = Date()
        let period = ConquestPeriod(startDate: start)

        let midDate = Calendar.current.date(byAdding: .day, value: 3, to: start)!
        let overDate = Calendar.current.date(byAdding: .day, value: 10, to: start)!

        logger.info("🧪 daysLeft")
        logger.info(" - from start: \(period.daysLeft(from: start), privacy: .public)")
        logger.info(" - from end: \(period.daysLeft(from: period.endDate), privacy: .public)")
        logger.info(" - from mid (3일 후): \(period.daysLeft(from: midDate), privacy: .public)")
        logger.info(" - from over (10일 후): \(period.daysLeft(from: overDate), privacy: .public)")

        XCTAssertEqual(period.daysLeft(from: start), 7)
        XCTAssertEqual(period.daysLeft(from: period.endDate), 0)
        XCTAssertEqual(period.daysLeft(from: midDate), 4)
        XCTAssertEqual(period.daysLeft(from: overDate), 0)
    }
}
