//
//  JoinedStringsTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class JoinedStringsTests: QuelboTests {
    let factory = Factories.JoinedStrings.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("STRING"))
    }

    func testJoinedStrings() throws {
        let symbol = try factory.init([
            .character("A"),
            .form([
                .atom("ASCII"),
                .decimal(66)
            ]),
            .string("CD")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
            ["A", 66.ascii, "CD"].joined()
            """,
            type: .string,
            children: [
                Symbol(
                    "\"A\"",
                    type: .string,
                    meta: [.isLiteral]
                ),
                Symbol(
                    "66.ascii",
                    type: .string,
                    children: [
                        Symbol(
                            "66",
                            type: .int,
                            meta: [.isLiteral]
                        )
                    ]
                ),
                Symbol(
                    "\"CD\"",
                    type: .string,
                    meta: [.isLiteral]
                )
            ]
        ))
    }
}
