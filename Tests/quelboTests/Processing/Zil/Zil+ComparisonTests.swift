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
    func testCompareAtomWithBool() throws {
        let zil = try Zil("L?")?.process([
            .atom(".ANSWER"),
            .decimal(43),
        ])

        XCTAssertNoDifference(zil, "answer < 43")
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

        XCTAssertNoDifference(zil, "ZIL.set(&n, to: (n - 1)) < 1")
    }
}
