//
//  Zil+ComparisonTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/13/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ZilComparisonTests: XCTestCase {
    func testCompareAtomWithDecimel() throws {
        let zil = try Zil("L?")?.process([
            .atom(".ANSWER"),
            .decimal(43),
        ])

        XCTAssertNoDifference(zil, "answer < 43")
    }

    func testCompareAtomEqualToMultipleValues() throws {
        let zil = try Zil("EQUAL?")?.process([
            .atom(".ANSWER"),
            .decimal(41),
            .decimal(42),
            .decimal(43),
        ])

        XCTAssertNoDifference(zil, "[41, 42, 43].contains { answer == $0 }")
    }

    func testCompareAtomNotEqualToMultipleValues() throws {
        let zil = try Zil("N==?")?.process([
            .atom(".ANSWER"),
            .decimal(41),
            .decimal(42),
            .decimal(43),
        ])

        XCTAssertNoDifference(zil, "[41, 42, 43].allSatisfy { answer != $0 }")
    }

    func testCompareAtomWithForm() throws {
        let zil = try Zil("L?")?.process([
            .form([
                .atom("SET"),
                .atom("N"),
                .form([
                    .atom("-"),
                    .atom(".N"),
                    .decimal(1)
                ])
            ]),
            .decimal(1),
        ])

        XCTAssertNoDifference(zil, "set(&n, to: (n - 1)) < 1")
    }
}
