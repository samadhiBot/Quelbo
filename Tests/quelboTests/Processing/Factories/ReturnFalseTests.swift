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
        AssertSameFactory(factory, Game.findFactory("RFALSE"))
    }

    func testReturnFalse() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "return false",
            type: .booleanFalse,
            isReturnStatement: true
        ))
    }

    func testReturnFalseBecomesReturnNil() throws {
        let symbol = try factory.init([], with: &localVariables).process()
        try symbol.assert(.hasType(.object))

        XCTAssertNoDifference(symbol, .statement(
            code: "return nil",
            type: .init(
                dataType: .object,
                confidence: .certain,
                isOptional: true
            ),
            isReturnStatement: true
        ))
    }

    func testAnyParamThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .bool(true)
            ], with: &localVariables).process()
        )
    }
}
