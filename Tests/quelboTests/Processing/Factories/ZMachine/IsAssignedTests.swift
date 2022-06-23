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
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("ASSIGNED?"))
    }

    func testIsAssigned() throws {
        let symbol = try factory.init([
            .local("FOO")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "foo.isAssigned",
            type: .bool
        ))
    }

    func testNonVariableThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
            ]).process()
        )
    }
}
