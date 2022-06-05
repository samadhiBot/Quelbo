//
//  SyntaxTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/5/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SyntaxTests: QuelboTests {
    let factory = Factories.Syntax.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("SYNTAX"))
    }

    func testQuitSyntax() throws {
        let symbol = try factory.init([
            .atom("QUIT"),
            .atom("="),
            .atom("V-QUIT")
        ]).process()

        let expected = Symbol(
            id: "<Syntax:quit>",
            code: """
                Syntax(
                    verb: "quit",
                    actionRoutine: vQuit
                )
                """,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("<Syntax:quit>", category: .syntax), expected)
    }

    func testContemplateSyntax() throws {
        let symbol = try factory.init([
            .atom("CONTEMPLATE"),
            .atom("OBJECT"),
            .atom("="),
            .atom("V-THINK-ABOUT")
        ]).process()

        let expected = Symbol(
            id: "<Syntax:contemplate>",
            code: """
                Syntax(
                    verb: "contemplate",
                    directObject: Syntax.Object(),
                    actionRoutine: vThinkAbout
                )
                """,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("<Syntax:contemplate>", category: .syntax), expected)
    }

    func testTakeSyntax() throws {
        let symbol = try factory.init([
            .atom("TAKE"),
            .atom("OBJECT"),
            .list([
                .atom("FIND"),
                .atom("TAKEBIT")
            ]),
            .list([
                .atom("MANY"),
                .atom("ON-GROUND"),
                .atom("IN-ROOM")
            ]),
            .atom("="),
            .atom("V-TAKE")
        ]).process()

        let expected = Symbol(
            id: "<Syntax:take>",
            code: """
                Syntax(
                    verb: "take",
                    directObject: Syntax.Object(
                        where: isTakable,
                        search: [.inRoom, .many, .onGround]
                    ),
                    actionRoutine: vTake
                )
                """,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("<Syntax:take>", category: .syntax), expected)
    }

    func testWaterSyntax() throws {
        let symbol = try factory.init([
            .atom("WATER"),
            .atom("OBJECT"),
            .list([
                .atom("FIND"),
                .atom("SPONGEBIT")
            ]),
            .atom("="),
            .atom("V-POUR-LIQUID"),
            .atom("PRE-WATER"),
            .atom("WATER")
        ]).process()

        let expected = Symbol(
            id: "<Syntax:water>",
            code: """
                Syntax(
                    verb: "water",
                    directObject: Syntax.Object(
                        where: spongeBit
                    ),
                    actionRoutine: vPourLiquid,
                    preActionRoutine: preWater
                )
                """,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("<Syntax:water>", category: .syntax), expected)
    }

    func testPutSyntax() throws {
        let symbol = try factory.init([
            .atom("PUT"),
            .atom("OBJECT"),
            .list([
                .atom("MANY"),
                .atom("TAKE"),
                .atom("HELD"),
                .atom("CARRIED")
            ]),
            .atom("IN"),
            .atom("OBJECT"),
            .list([
                .atom("FIND"),
                .atom("CONTBIT")
            ]),
            .atom("="),
            .atom("V-PUT-IN"),
            .atom("PRE-PUT-IN")
        ]).process()

        let expected = Symbol(
            id: "<Syntax:put>",
            code: """
                Syntax(
                    verb: "put",
                    directObject: Syntax.Object(
                        search: [.carried, .held, .many, .take]
                    ),
                    indirectObject: Syntax.Object(
                        preposition: "in",
                        where: isContainer
                    ),
                    actionRoutine: vPutIn,
                    preActionRoutine: prePutIn
                )
                """,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("<Syntax:put>", category: .syntax), expected)
    }

    func testWakeSyntax() throws {
        let symbol = try factory.init([
            .atom("WAKE"),
            .atom("OBJECT"),
            .list([
                .atom("FIND"),
                .atom("PERSONBIT")
            ]),
            .atom("="),
            .atom("V-WAKE")
        ]).process()

        let expected = Symbol(
            id: "<Syntax:wake>",
            code: """
                Syntax(
                    verb: "wake",
                    directObject: Syntax.Object(
                        where: isPerson
                    ),
                    actionRoutine: vWake
                )
                """,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("<Syntax:wake>", category: .syntax), expected)
    }

    func testWakeUpSyntax() throws {
        let symbol = try factory.init([
            .atom("WAKE"),
            .atom("UP"),
            .atom("OBJECT"),
            .list([
                .atom("FIND"),
                .atom("PERSONBIT")
            ]),
            .atom("="),
            .atom("V-WAKE")
        ]).process()

        let expected = Symbol(
            id: "<Syntax:wake>",
            code: """
                Syntax(
                    verb: "wake",
                    directObject: Syntax.Object(
                        preposition: "up",
                        where: isPerson
                    ),
                    actionRoutine: vWake
                )
                """,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("<Syntax:wake>", category: .syntax), expected)
    }

    func testWakeKludgeSyntax() throws {
        let symbol = try factory.init([
            .atom("WAKE"),
            .atom("OBJECT"),
            .list([
                .atom("FIND"),
                .atom("PERSONBIT")
            ]),
            .atom("UP"),
            .atom("OBJECT"),
            .list([
                .atom("FIND"),
                .atom("KLUDGEBIT")
            ]),
            .atom("="),
            .atom("V-WAKE")
        ]).process()

        let expected = Symbol(
            id: "<Syntax:wake>",
            code: """
                Syntax(
                    verb: "wake",
                    directObject: Syntax.Object(
                        where: isPerson
                    ),
                    indirectObject: Syntax.Object(
                        preposition: "up",
                        where: shouldKludge
                    ),
                    actionRoutine: vWake
                )
                """,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("<Syntax:wake>", category: .syntax), expected)
    }
}
