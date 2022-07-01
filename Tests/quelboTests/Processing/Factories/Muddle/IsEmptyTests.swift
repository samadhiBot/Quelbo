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
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("EMPTY?"))
    }

    func testIsEmpty() throws {
        registry.insert(
            Symbol(id: "atms", type: .variable(.bool))
        )

        let symbol = try factory.init([
            .local("ATMS")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "atms.isEmpty",
            type: .bool
        ))
    }
}
