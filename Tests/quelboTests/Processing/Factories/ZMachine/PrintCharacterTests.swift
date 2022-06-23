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
            Symbol(id: "letterZ", type: .string, category: .globals)
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
            type: .void
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
            type: .void
        ))
    }

    func testProcessAtom() throws {
        let symbol = try factory.init([
            .global("LETTER-Z")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "output(letterZ)",
            type: .void
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
            type: .void
        ))
    }
}
