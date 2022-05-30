//
//  MapStopTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class MapStopTests: QuelboTests {
    let factory = Factories.MapStop.self

    override func setUp() {
        super.setUp()

        try! Game.commit(
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("MAPSTOP"))
    }

    func testMapStop() throws {
        let symbol = try factory.init([
            .local("ATMS")
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            "atms.mapStop",
            type: .bool,
            children: [
                Symbol("atms")
            ]
        ))
    }
}
