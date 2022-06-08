//
//  ParentTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/7/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ParentTests: QuelboTests {
    let factory = Factories.Parent.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol("clearing", type: .object, category: .rooms),
            Symbol("thief", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("LOC"))
    }

    func testThiefsLocation() throws {
        let symbol = try factory.init([
            .global("THIEF")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "thief.parent",
            type: .object,
            children: [
                Symbol("thief", type: .object, category: .objects)
            ]
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("thief")
            ])
        )
    }
}
