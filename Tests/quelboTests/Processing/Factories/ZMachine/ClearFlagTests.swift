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
            Symbol(id: "openBit", type: .bool, category: .globals),
            Symbol(id: "trapDoor", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("FCLEAR"))
    }

    func testClearFlag() throws {
        let symbol = try factory.init([
            .global("TRAP-DOOR"),
            .global("OPENBIT"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "trapDoor.openBit = false",
            type: .void
        ))
    }

    func testNonBoolFlagThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .global("TRAP-DOOR"),
                .string("11"),
            ]).process()
        )
    }
}
