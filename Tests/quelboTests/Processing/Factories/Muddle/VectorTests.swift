//
//  VectorTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class VectorTests: QuelboTests {
    let factory = Factories.Vector.self

    override func setUp() {
        super.setUp()

        Game.commit(
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("VECTOR"))
    }

    func testVector() throws {
        let symbol = try factory.init([
            .decimal(1),
            .decimal(2),
            .string("AB"),
            .character("C")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: #"[1, 2, "AB", "C"]"#,
            type: .array(.zilElement)
        ))
    }
}
