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

        try! Game.commit(
            Symbol(id: "message", type: .string, category: .globals)
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PRINT"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PRINTB"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PRINTI"))
    }

    func testPrintString() throws {
        let symbol = try factory.init([
            .string("Hello World")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            #"output("Hello World")"#,
            type: .void
        ))
    }

    func testPrintAtom() throws {
        let symbol = try factory.init([
            .global("MESSAGE")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "output(message)",
            type: .void
        ))
    }
}
