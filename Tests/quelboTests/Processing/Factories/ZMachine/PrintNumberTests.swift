//
//  PrintNumberTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/2/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PrintNumberTests: QuelboTests {
    let factory = Factories.PrintNumber.self

    override func setUp() {
        super.setUp()

        try! Game.commit(
            Symbol("message", type: .string, category: .globals)
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PRINTN"))
    }

    func testProcessDecimal() throws {
        let symbol = try factory.init([
            .decimal(2)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "output(2)",
            type: .void,
            children: [
                Symbol("2", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testProcessMultipleDecimals() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .decimal(3),
            ]).process()
        )
    }

    func testProcessAtom() throws {
        let symbol = try factory.init([
            .atom("INFINITY")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "output(infinity)",
            type: .void,
            children: [
                Symbol("infinity", type: .int),
            ]
        ))
    }

    func testProcessForm() throws {
        let symbol = try factory.init([
            .form([
                .atom("ADD"),
                .decimal(2),
                .decimal(3),
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "output(.add(2, 3))",
            type: .void,
            children: [
                Symbol(
                    ".add(2, 3)",
                    type: .int,
                    children: [
                        Symbol("2", type: .int, meta: [.isLiteral]),
                        Symbol("3", type: .int, meta: [.isLiteral]),
                    ]
                ),
            ]
        ))
    }
}
