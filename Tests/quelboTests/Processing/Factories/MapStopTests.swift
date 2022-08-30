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

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("MAPSTOP"))
    }

    func testMapStop() throws {
        localVariables.append(
            Variable(id: "atms", type: .array(.string), confidence: .certain)
        )

        let symbol = try factory.init([
            .local("ATMS")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "return atms",
            type: .array(.string),
            confidence: .certain
        ))
    }
}
