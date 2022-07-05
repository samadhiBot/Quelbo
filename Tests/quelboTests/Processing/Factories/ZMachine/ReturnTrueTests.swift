//
//  ReturnTrueTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ReturnTrueTests: QuelboTests {
    let factory = Factories.ReturnTrue.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("RTRUE"))
    }

    func testReturnTrue() throws {
        let symbol = try factory.init([], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "return true",
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
                .bool(false)
            ], with: &registry).process()
        )
    }
}
