//
//  PrintTableTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PrintTableTests: QuelboTests {
    let factory = Factories.PrintTable.self

    override func setUp() {
        super.setUp()

        try! Game.commit([fooTable])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PRINTF"))
    }

    func testPrintTable() throws {
        let symbol = try factory.init([
            .atom("FOO")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            #"""
            output("""
                \(.room(forest1))
                \(.room(forest2))
                \(.room(forest3))
            """)
            """#,
            type: .void,
            children: [
                fooTable.with(code: "foo")
            ]
        ))
    }

    func testThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ]).process()
        )
    }
}
