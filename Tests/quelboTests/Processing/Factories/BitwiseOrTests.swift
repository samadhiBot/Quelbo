//
//  BitwiseOrTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class BitwiseOrTests: QuelboTests {
    let factory = Factories.BitwiseOr.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "someInt", type: .int, category: .globals),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("BOR"))
        AssertSameFactory(factory, Game.findFactory("ORB"))
    }

    func testBitwiseOr() throws {
        let symbol = try factory.init([
            .decimal(1),
            .decimal(0),
            .decimal(2),
            .global("SOME-INT"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".bitwiseOr(1, 0, 2, someInt)",
            type: .int,
            confidence: .certain
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
