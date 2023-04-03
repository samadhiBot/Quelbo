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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "advFunc",
            code: "advFunc: 0",
            type: .integerZero
        ))
    }

    func testEmptyThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ], with: &localVariables).process()
        )
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(4),
                .decimal(5),
            ], with: &localVariables).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("4")
            ], with: &localVariables).process()
        )
    }
}
