//
//  StackPopTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/24/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class StackPopTests: QuelboTests {
    let factory = Factories.StackPop.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("RSTACK"))
    }

    func testStackPopDecimal() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Stack.pop()",
            type: .someTableElement
        ))
    }

    func testStackPopAnyArgumentsThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
            ], with: &localVariables).process()
        )
    }
}
