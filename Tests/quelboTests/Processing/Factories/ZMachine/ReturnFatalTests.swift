//
//  ReturnFatalTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ReturnFatalTests: QuelboTests {
    let factory = Factories.ReturnFatal.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("RFATAL"))
    }

    func testReturnFatal() throws {
        let symbol = try factory.init([], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(code: "returnFatal()", type: .void))
    }

    func testReturnFatalWithParameterThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42),
            ], with: &registry).process()
        )
    }
}
