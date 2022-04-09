//
//  CrlfTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class CrlfTests: QuelboTests {
    let factory = Factories.Crlf.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("CRLF"))
    }

    func testCrlf() throws {
        let symbol = try factory.init([]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "output(carriageReturn)",
            type: .void
        ))
    }

    func testThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42)
            ]).process()
        )
    }
}
