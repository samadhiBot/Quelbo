//
//  GetTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GetTests: QuelboTests {
    let factory = Factories.Get.self

    override func setUp() {
        super.setUp()

        try! Game.commit([fooTable])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("GET"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("GETB"))
    }

    func testGet() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .decimal(2)
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            "foo[2]",
            type: .zilElement,
            children: [
                fooTable.with(code: "foo"),
                Symbol("2", type: .int, meta: [.isLiteral])
            ]
        ))
    }

    func testThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("FOO"),
                .decimal(2)
            ], with: types).process()
        )
    }
}
