//
//  DeclareTypeTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/23/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DeclareTypeTests: QuelboTests {
    let factory = Factories.DeclareType.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("#DECL"))
    }

    func testDeclareType() throws {
        let symbol = try factory.init([
            .list([
                .atom("BEACH-DIG")
            ]),
            .atom("FIX")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "// Declare(beachDig: Int)",
            type: .comment
        ))
    }

    func testMultiDeclareType() throws {
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
                // Declare(
                //     ms: Int,
                //     wd: Int,
                //     rs: Int
                // )
                """,
            type: .comment
        ))
    }

    func testMultiDeclareTypeFormValue() throws {
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
                // Declare(
                //     verbose: .or(atom, false),
                //     superBrief: .or(atom, false)
                // )
                """,
            type: .comment
        ))
    }

    func testDeclareTypePrimType() throws {
        let symbol = try factory.init(
            try parse("(C E) <PRIMTYPE VECTOR>"),
            with: &localVariables
        ).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "// Declare(c: Array, e: Array)",
            type: .comment
        ))
    }

    func testDeclareTypeOrFalseAtom() throws {
        let symbol = try factory.init(
            try parse("(FLG) <OR FALSE ATOM>"),
            with: &localVariables
        ).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                  // Declare(
                  //     flg: .or(false, atom)
                  // )
                  """,
            type: .comment
        ))
    }
}
