//
//  IsAssignedTests.swift.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsAssignedTests: QuelboTests {
    let factory = Factories.IsAssigned.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("ASSIGNED?"))
    }

    func testIsAssigned() throws {
        localVariables.append(
            Variable(id: "foo", type: .bool)
        )

        let symbol = try factory.init([
            .local("FOO")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "foo.isAssigned",
            type: .bool
        ))
    }

    func testNonVariableThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
            ], with: &localVariables).process()
        )
    }
}
