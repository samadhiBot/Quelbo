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

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("RFALSE"))
    }

    func testReturnTrue() throws {
        let symbol = try factory.init([], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "return false",
            type: .bool,
            meta: [.controlFlow(.returnValue(type: .bool))]
        ))
    }

    func testIsReturnStatement() throws {
        let symbol = try factory.init([], with: &registry).process()

        XCTAssertTrue(symbol.isReturnStatement)
    }

    func testAnyParamThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .bool(true)
            ], with: &registry).process()
        )
    }
}
