//
//  VerifyTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class VerifyTests: QuelboTests {
    let factory = Factories.Verify.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("VERIFY"))
    }

    func testVerify() throws {
        let symbol = try factory.init([]).process()

        XCTAssertNoDifference(symbol, Symbol("verify()", type: .void))
    }

    func testVerifyWithParameterThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42),
            ]).process()
        )
    }
}
