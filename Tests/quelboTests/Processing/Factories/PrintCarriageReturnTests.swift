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

        try! Game.commit([
            .variable(id: "message", type: .string, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("PRINTR"))
    }

    func testPrintString() throws {
        let symbol = try factory.init([
            .string("Hello World")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"""
                output("Hello World")
                output("\n")
                """#,
            type: .void
        ))
    }

    func testPrintAtom() throws {
        let symbol = try factory.init([
            .global(.atom("MESSAGE"))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"""
                output(message)
                output("\n")
                """#,
            type: .void
        ))
    }

    func testPrintDecimal() throws {
        let symbol = try factory.init([
            .decimal(42)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"""
                output(42)
                output("\n")
                """#,
            type: .void
        ))
    }
}
