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

        try! Game.commit(
            Symbol("letterZ", type: .string, category: .globals)
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PRINTC"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PRINTU"))
    }

    func testProcessDecimal() throws {
        let symbol = try factory.init([
            .decimal(90)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            #"output(utf8: 90)"#,
            type: .void,
            children: [
                Symbol("90", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testProcessMultipleDecimals() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(89),
                .decimal(90),
            ]).process()
        )
    }

    func testPrintCharacterBangEscaped() throws {
        let symbol = try factory.init([
            .character("s"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            #"output("s")"#,
            type: .void,
            children: [
                Symbol(#""s""#, type: .string, meta: [.isLiteral]),
            ]
        ))
    }

    func testProcessAtom() throws {
        let symbol = try factory.init([
            .global("LETTER-Z")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "output(letterZ)",
            type: .void,
            children: [
                Symbol("letterZ", type: .string, category: .globals),
            ]
        ))
    }

    func testProcessForm() throws {
        let symbol = try factory.init([
            .form([
                .atom("ADD"),
                .decimal(2),
                .decimal(88),
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "output(utf8: .add(2, 88))",
            type: .void,
            children: [
                Symbol(
                    ".add(2, 88)",
                    type: .int,
                    children: [
                        Symbol("2", type: .int, meta: [.isLiteral]),
                        Symbol("88", type: .int, meta: [.isLiteral]),
                    ]
                ),
            ]
        ))
    }
}
