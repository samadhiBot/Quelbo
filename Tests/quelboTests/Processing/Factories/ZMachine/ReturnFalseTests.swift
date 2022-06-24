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
        let symbol = try factory.init([]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return false",
            type: .bool,
            meta: [.isLiteral, .maybeEmptyValue]
        ))
    }

    func testIsReturnStatement() throws {
        let symbol = try factory.init([]).process()

        XCTAssertTrue(symbol.isReturnStatement)
    }

    func testAnyParamThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .bool(true)
            ]).process()
        )
    }
}
