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
        AssertSameFactory(factory, Game.findFactory("SYNTAX"))
    }

    func testQuitSyntax() throws {
        let symbol = try factory.init([
            .atom("QUIT"),
            .atom("="),
            .atom("V-QUIT")
        ], with: &localVariables).process()

        let expected = Statement(
            id: "quit",
            code: """
                Syntax(
                    verb: "quit",
                    actionRoutine: vQuit
                )
                """,
            type: .void,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.shared.symbols.find("quit"), expected)
    }

    func testContemplateSyntax() throws {
        let symbol = try factory.init([
            .atom("CONTEMPLATE"),
            .atom("OBJECT"),
            .atom("="),
            .atom("V-THINK-ABOUT")
        ], with: &localVariables).process()

        let expected = Statement(
            id: "contemplate",
            code: """
                Syntax(
                    verb: "contemplate",
                    directObject: Syntax.Object(),
                    actionRoutine: vThinkAbout
                )
                """,
            type: .void,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.shared.symbols.find("contemplate"), expected)
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
        ], with: &localVariables).process()

        let expected = Statement(
            id: "take",
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
            type: .void,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.shared.symbols.find("take"), expected)
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
        ], with: &localVariables).process()

        let expected = Statement(
            id: "water",
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
            type: .void,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.shared.symbols.find("water"), expected)
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
        ], with: &localVariables).process()

        let expected = Statement(
            id: "put",
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
            type: .void,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.shared.symbols.find("put"), expected)
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
        ], with: &localVariables).process()

        let expected = Statement(
            id: "wake",
            code: """
                Syntax(
                    verb: "wake",
                    directObject: Syntax.Object(
                        where: isPerson
                    ),
                    actionRoutine: vWake
                )
                """,
            type: .void,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.shared.symbols.find("wake"), expected)
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
        ], with: &localVariables).process()

        let expected = Statement(
            id: "wake",
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
            type: .void,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.shared.symbols.find("wake"), expected)
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
        ], with: &localVariables).process()

        let expected = Statement(
            id: "wake",
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
            type: .void,
            category: .syntax
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.shared.symbols.find("wake"), expected)
    }
}
