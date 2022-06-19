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
            Symbol("someInt", type: .int, category: .globals),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("BOR"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("ORB"))
    }

    func testBitwiseOr() throws {
        let symbol = try factory.init([
            .decimal(1),
            .decimal(0),
            .decimal(2),
            .global("SOME-INT"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".bitwiseOr(1, 0, 2, someInt)",
            type: .int,
            children: [
                Symbol("1", type: .int, meta: [.isLiteral]),
                .zeroSymbol,
                Symbol("2", type: .int, meta: [.isLiteral]),
                Symbol("someInt", type: .int, category: .globals),
            ]
        ))
    }

    func testNonIntegerThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
                .decimal(0),
                .string("three"),
            ]).process()
        )
    }
}
