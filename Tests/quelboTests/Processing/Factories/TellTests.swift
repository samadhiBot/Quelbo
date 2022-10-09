//
//  TellTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class TellTests: QuelboTests {
    let factory = Factories.Tell.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "troll", type: .object, category: .objects)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("TELL"))
    }

    func testTell() throws {
        let symbol = try factory.init([
            .string("You are in a large cavernous room"),
            .atom("CR"),
            .atom("CRLF"),
            .atom("D"),
            .global(.atom("TROLL")),
            .atom("N"),
            .decimal(42),
            .atom("C"),
            .character("z"),
            .atom("C"),
            .decimal(65),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
            output("You are in a large cavernous room")
            output(troll.description)
            output(42)
            output("z")
            output(utf8: 65)
            """,
            type: .void
        ))
    }

    func testThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ], with: &localVariables).process()
        )
    }
}
