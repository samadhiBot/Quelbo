//
//  AsciiTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class AsciiTests: QuelboTests {
    let factory = Factories.Ascii.self

    override func setUp() {
        super.setUp()

        try! Game.commit(
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("ASCII"))
    }

    func testAsciiCharacterToDecimal() throws {
        let symbol = try factory.init([
            .character("A")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "\"A\".ascii",
            type: .int
        ))
    }

    func testAsciiDecimalToCharacter() throws {
        let symbol = try factory.init([
            .decimal(65)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "65.ascii",
            type: .string
        ))
    }
}
