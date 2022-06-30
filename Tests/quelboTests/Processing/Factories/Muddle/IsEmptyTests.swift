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
        let symbol = try factory.init([
            .local("ATMS")
        ], with: [
            Symbol(id: "atms", type: .variable(.bool))
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "atms.isEmpty",
            type: .bool
        ))
    }
}
