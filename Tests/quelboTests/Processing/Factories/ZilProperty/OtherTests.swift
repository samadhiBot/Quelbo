//
//  OtherTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class OtherTests: QuelboTests {
    let factory = Factories.Other.self

    func testOther() throws {
        let symbol = try factory.init([
            .atom("ADVFCN"),
            .decimal(0)
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "advfcn",
            code: "advfcn: 0",
            type: .int
        ))
    }

    func testEmptyThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ], with: &registry).process()
        )
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(4),
                .decimal(5),
            ], with: &registry).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("4")
            ], with: &registry).process()
        )
    }
}
