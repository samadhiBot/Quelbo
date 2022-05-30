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

        try! Game.commit(
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
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            #"[1, 2, "AB", "C"]"#,
            type: .array(.zilElement),
            children: [
                Symbol("1", type: .int, meta: [.isLiteral]),
                Symbol("2", type: .int, meta: [.isLiteral]),
                Symbol("\"AB\"", type: .string, meta: [.isLiteral]),
                Symbol("\"C\"", type: .string, meta: [.isLiteral]),
            ]
        ))
    }
}
