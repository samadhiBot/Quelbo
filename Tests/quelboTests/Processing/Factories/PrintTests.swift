//
//  PrintTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/2/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PrintTests: QuelboTests {
    let factory = Factories.Print.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "message", type: .string, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("PRINT"))
        AssertSameFactory(factory, Game.findFactory("PRINTB"))
        AssertSameFactory(factory, Game.findFactory("PRINTI"))
    }

    func testPrintString() throws {
        let symbol = try factory.init([
            .string("Hello World")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"output("Hello World")"#,
            type: .void
        ))
    }

    func testPrintAtom() throws {
        let symbol = try factory.init([
            .global(.atom("MESSAGE"))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "output(message)",
            type: .void
        ))
    }
}
