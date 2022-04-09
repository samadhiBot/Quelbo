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
            Symbol("trapDoor", type: .object, category: .objects)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("FCLEAR"))
    }

    func testClearFlag() throws {
        let symbol = try factory.init([
            .atom(",TRAP-DOOR"),
            .atom(",OPENBIT"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "trapDoor.openbit = false",
            type: .void,
            children: [
                Symbol(
                    id: "trapDoor",
                    code: "trapDoor",
                    type: .object,
                    category: .objects
                ),
                Symbol(
                    id: "openbit",
                    code: "openbit",
                    type: .bool
                )
            ]
        ))
    }

    func testNonBoolFlagThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom(",TRAP-DOOR"),
                .decimal(11),
            ]).process()
        )
    }
}
