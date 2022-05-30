//
//  InitStatusLineTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/20/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class InitStatusLineTests: QuelboTests {
    let factory = Factories.InitStatusLine.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("INIT-STATUS-LINE"))
    }

    func testInitStatusLine() throws {
        let symbol = try factory.init([], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            "initStatusLine()",
            type: .void
        ))
    }
}
