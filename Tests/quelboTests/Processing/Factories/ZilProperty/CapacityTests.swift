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
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("CAPACITY"))
    }

    func testCapacity() throws {
        let symbol = try factory.init([
            .decimal(6)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "capacity",
            code: "capacity: 6",
            type: .int,
            children: [
                Symbol("6", type: .int)
            ]
        ))
    }

    func testEmptyThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ]).process()
        )
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(4),
                .decimal(5),
            ]).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("4")
            ]).process()
        )
    }
}
