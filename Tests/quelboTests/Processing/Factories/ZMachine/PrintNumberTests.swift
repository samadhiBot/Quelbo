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
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "output(2)",
            type: .void
        ))
    }

    func testProcessMultipleDecimals() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .decimal(3),
            ], with: &registry).process()
        )
    }

    func testProcessAtom() throws {
        let symbol = try factory.init([
            .atom("INFINITY")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "output(infinity)",
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
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "output(.add(2, 3))",
            type: .void
        ))
    }
}
