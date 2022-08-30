//
//  GlobalTypeTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/19/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GlobalTypeTests: QuelboTests {
    let factory = Factories.GlobalType.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("GDECL"))
    }

    func testGlobalType() throws {
        try Factories.Global([
            .atom("BEACH-DIG"),
            .bool(false),
        ], with: &localVariables).process()

        let symbol = try factory.init([
            .list([
                .atom("BEACH-DIG")
            ]),
            .atom("FIX")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "// GlobalType beachDig: Int",
            type: .comment,
            confidence: .certain
        ))

        XCTAssertNoDifference(Game.findGlobal("beachDig"), Variable(
            id: "beachDig",
            type: .int,
            confidence: .certain,
            category: .globals
        ))
    }

    func testMultiGlobalType() throws {
        try Factories.Global([
            .atom("MS"),
            .bool(false),
        ], with: &localVariables).process()

        try Factories.Global([
            .atom("WD"),
            .decimal(0),
        ], with: &localVariables).process()

        let symbol = try factory.init([
            .list([
                .atom("MS"),
                .atom("WD"),
                .atom("RS")
            ]),
            .atom("FIX")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                // GlobalType ms: Int
                // GlobalType wd: Int
                // GlobalType rs: Int
                """,
            type: .comment,
            confidence: .certain
        ))

        XCTAssertNoDifference(Game.findGlobal("ms"), Variable(
            id: "ms",
            type: .int,
            confidence: .certain,
            category: .globals
        ))

        XCTAssertNoDifference(Game.findGlobal("wd"), Variable(
            id: "wd",
            type: .int,
            confidence: .integerZero,
            category: .globals
        ))

        XCTAssertNoDifference(Game.findGlobal("rs"), Variable(
            id: "rs",
            type: .int,
            confidence: .certain,
            category: .globals
        ))
    }

    func testMultiGlobalTypeFormValue() throws {
        try Factories.Global([
            .atom("VERBOSE"),
            .bool(false),
        ], with: &localVariables).process()

        try Factories.Global([
            .atom("SUPER-BRIEF"),
            .bool(false),
        ], with: &localVariables).process()

        let symbol = try factory.init([
            .list([
                .atom("VERBOSE"),
                .atom("SUPER-BRIEF")
            ]),
            .form([
                .atom("OR"),
                .atom("ATOM"),
                .atom("FALSE")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                // GlobalType verbose: Bool
                // GlobalType superBrief: Bool
                """,
            type: .comment,
            confidence: .certain
        ))

        XCTAssertNoDifference(Game.findGlobal("verbose"), Variable(
            id: "verbose",
            type: .bool,
            confidence: .booleanFalse,
            category: .globals
        ))

        XCTAssertNoDifference(Game.findGlobal("superBrief"), Variable(
            id: "superBrief",
            type: .bool,
            confidence: .booleanFalse,
            category: .globals
        ))
    }
}
