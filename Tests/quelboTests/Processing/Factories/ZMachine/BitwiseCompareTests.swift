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
            Symbol("someInt", type: .int, category: .globals),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("BTST"))
    }

    func testBitwiseCompare() throws {
        let symbol = try factory.init([
            .decimal(1),
            .decimal(0),
            .decimal(2),
            .global("SOME-INT"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".bitwiseCompare(1, 0, 2, someInt)",
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
