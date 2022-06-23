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

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PRINTN"))
    }

    func testProcessDecimal() throws {
        let symbol = try factory.init([
            .decimal(2)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "output(2)",
            type: .void
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
            type: .void
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
            type: .void
        ))
    }
}
