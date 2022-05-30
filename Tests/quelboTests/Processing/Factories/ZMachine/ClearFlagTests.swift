//
//  ClearFlagTests.swift.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ClearFlagTests: QuelboTests {
    let factory = Factories.ClearFlag.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol("openBit", type: .bool, category: .globals),
            Symbol("trapDoor", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("FCLEAR"))
    }

    func testClearFlag() throws {
        let symbol = try factory.init([
            .global("TRAP-DOOR"),
            .global("OPENBIT"),
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            "trapDoor.openBit = false",
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

    func testNonBoolFlagThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .global("TRAP-DOOR"),
                .string("11"),
            ], with: types).process()
        )
    }
}
