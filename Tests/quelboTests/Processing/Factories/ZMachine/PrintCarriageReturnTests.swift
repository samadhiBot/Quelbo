//
//  PrintCarriageReturnTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PrintCarriageReturnTests: QuelboTests {
    let factory = Factories.PrintCarriageReturn.self

    override func setUp() {
        super.setUp()

        Game.commit([
            Symbol(id: "message", type: .string, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PRINTR"))
    }

    func testPrintString() throws {
        let symbol = try factory.init([
            .string("Hello World")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: #"""
                output("Hello World")
                output("\n")
                """#,
            type: .void
        ))
    }

    func testPrintAtom() throws {
        let symbol = try factory.init([
            .global("MESSAGE")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: #"""
                output(message)
                output("\n")
                """#,
            type: .void
        ))
    }

    func testNonStringThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(99)
            ], with: &registry).process()
        )
    }
}
