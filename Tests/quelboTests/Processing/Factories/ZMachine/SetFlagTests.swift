//
//  SetFlagTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SetFlagTests: QuelboTests {
    let factory = Factories.SetFlag.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol("openBit", type: .bool, category: .globals),
            Symbol("trapDoor", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("FSET"))
    }

    func testSetFlag() throws {
        let symbol = try factory.init([
            .global("TRAP-DOOR"),
            .global("OPENBIT"),
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            "trapDoor.openBit = true",
            type: .void,
            children: [
                Symbol(
                    id: "trapDoor",
                    code: "trapDoor",
                    type: .object,
                    category: .objects
                ),
                Symbol(
                    id: "openBit",
                    code: "openBit",
                    type: .bool,
                    category: .globals
                )
            ]
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("Trap Door"),
                .global("OPENBIT"),
            ], with: types).process()
        )
    }
}
