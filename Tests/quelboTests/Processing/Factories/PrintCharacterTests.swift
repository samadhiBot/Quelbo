//
//  PrintCharacterTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/4/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PrintCharacterTests: QuelboTests {
    let factory = Factories.PrintCharacter.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "letterZ", type: .string, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("PRINTC"))
        AssertSameFactory(factory, Game.findFactory("PRINTU"))
    }

    func testProcessDecimal() throws {
        let symbol = try factory.init([
            .decimal(90)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"output(utf8: 90)"#,
            type: .void
        ))
    }

    func testPrintCharacterMultipleArgs() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(89),
                .decimal(90),
            ], with: &localVariables).process()
        )
    }

    func testPrintCharacterInvalidType() throws {
        localVariables.append(.init(id: "troll", type: .object))

        XCTAssertThrowsError(
            try factory.init([
            ], with: &localVariables).process()
        )
    }

    func testPrintCharacterBangEscaped() throws {
        let symbol = try factory.init([
            .character("s"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"output("s")"#,
            type: .void
        ))
    }

    func testProcessAtom() throws {
        let symbol = try factory.init([
            .global(.atom("LETTER-Z"))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "output(letterZ)",
            type: .void
        ))
    }

    func testprocess() throws {
        let symbol = try factory.init([
            .form([
                .atom("ADD"),
                .decimal(2),
                .decimal(88),
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "output(utf8: 2.add(88))",
            type: .void
        ))
    }
}
