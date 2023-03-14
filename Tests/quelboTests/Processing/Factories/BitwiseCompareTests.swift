//
//  BitwiseCompareTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class BitwiseCompareTests: QuelboTests {
    let factory = Factories.BitwiseCompare.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "someInt", type: .int, category: .globals),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("BTST"))
    }

    func testBitwiseCompare() throws {
        let symbol = try factory.init([
            .decimal(1),
            .decimal(0),
            .decimal(2),
            .global(.atom("SOME-INT")),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".bitwiseCompare(1, 0, 2, Global.someInt)",
            type: .int
        ))
    }

    func testNonIntegerThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
                .decimal(0),
                .string("three"),
            ], with: &localVariables).process()
        )
    }
}
