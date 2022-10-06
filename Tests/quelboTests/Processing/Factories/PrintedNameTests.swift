//
//  PrintedNameTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/21/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PrintedNameTests: QuelboTests {
    let factory = Factories.PrintedName.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "troll", type: .object, category: .objects)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("PNAME"))
        AssertSameFactory(factory, Game.findFactory("SPNAME"))
    }

    func testPrintedName() throws {
        let symbol = try factory.init([
            .global("TROLL")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "troll.id",
            type: .string
        ))
    }

    func testProcessMultipleArguments() throws {
        XCTAssertThrowsError(
            try factory.init([
                .global("TROLL"),
                .global("TROLL"),
            ], with: &localVariables).process()
        )
    }

    func testProcessNonVariable() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
            ], with: &localVariables).process()
        )
    }
}
