//
//  ReturnFalseTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ReturnFalseTests: QuelboTests {
    let factory = Factories.ReturnFalse.self

    override func setUp() {
        super.setUp()

        try! Game.commit([

        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("RFALSE"))
    }

    func testReturnTrue() throws {
        let symbol = try factory.init([]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "return false",
            type: .bool
        ))
    }

    func testAnyParamThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .bool(true)
            ]).process()
        )
    }
}
