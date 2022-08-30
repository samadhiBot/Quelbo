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
            code: "// DeclareType beachDig: Int",
            type: .comment,
            confidence: .certain
        ))

        XCTAssertNoDifference(findLocalVariable("beachDig"), Variable(
            id: "beachDig",
            type: .int,
            confidence: .certain
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
                // DeclareType ms: Int
                // DeclareType wd: Int
                // DeclareType rs: Int
                """,
            type: .comment,
            confidence: .certain
        ))

        XCTAssertNoDifference(findLocalVariable("ms"), Variable(
            id: "ms",
            type: .int,
            confidence: .certain
        ))

        XCTAssertNoDifference(findLocalVariable("wd"), Variable(
            id: "wd",
            type: .int,
            confidence: .certain
        ))

        XCTAssertNoDifference(findLocalVariable("rs"), Variable(
            id: "rs",
            type: .int,
            confidence: .certain
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
                // DeclareType verbose: Bool
                // DeclareType superBrief: Bool
                """,
            type: .comment,
            confidence: .certain
        ))

        XCTAssertNoDifference(findLocalVariable("verbose"), Variable(
            id: "verbose",
            type: .bool,
            confidence: .certain
        ))

        XCTAssertNoDifference(findLocalVariable("superBrief"), Variable(
            id: "superBrief",
            type: .bool,
            confidence: .certain
        ))
    }
}
