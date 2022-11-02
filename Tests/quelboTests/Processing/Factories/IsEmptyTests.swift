//
//  IsEmptyTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsEmptyTests: QuelboTests {
    let factory = Factories.IsEmpty.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("EMPTY?"))
    }

    func testIsEmpty() throws {
        localVariables.append(
            Statement(id: "atms", type: .bool)
        )

        let symbol = try factory.init([
            .local("ATMS")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "atms.isEmpty",
            type: .bool
        ))
    }
}
