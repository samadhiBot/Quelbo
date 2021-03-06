//
//  LocalValueTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class LocalValueTests: QuelboTests {
    let factory = Factories.LocalValue.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("LVAL"))
    }

    func testAtom() throws {
        let symbol = try factory.init([
            .atom("foo")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(id: "foo", code: "foo"))
    }
}
