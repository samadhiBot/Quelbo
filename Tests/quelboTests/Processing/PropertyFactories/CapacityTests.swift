//
//  CapacityTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class CapacityTests: QuelboTests {
    let factory = Factories.Capacity.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findPropertyFactory("CAPACITY"))
    }

    func testCapacity() throws {
        let symbol = try factory.init([
            .decimal(6)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "capacity",
            code: "capacity: 6",
            type: .int,
            confidence: .certain
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "capacity",
            type: .int,
            confidence: .certain
        ))
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
