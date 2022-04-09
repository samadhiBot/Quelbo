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
            Symbol("message", type: .string, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PRINTR"))
    }

    func testPrintString() throws {
        let symbol = try factory.init([
            .string("Hello World")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            #"""
                output("Hello World")
                output(carriageReturn)
                """#,
            type: .void,
            children: [
                Symbol(#""Hello World""#, type: .string),
            ]
        ))
    }

    func testPrintAtom() throws {
        let symbol = try factory.init([
            .atom(",MESSAGE")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                output(message)
                output(carriageReturn)
                """,
            type: .void,
            children: [
                Symbol("message", type: .string, category: .globals),
            ]
        ))
    }

    func testNonStringThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .bool(false)
            ]).process()
        )
    }
}
