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

        try! Game.commit(fooTable)
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("GET"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("GETB"))
    }

    func testGet() throws {
        let symbol = try factory.init([
            .global("FOO"),
            .decimal(2)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "try foo.get(at: 2)",
            type: .zilElement
        ))
    }

    func testNonTableThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("FOO"),
                .decimal(2)
            ]).process()
        )
    }

    func testNonIndexThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .global("FOO"),
                .string("2")
            ]).process()
        )
    }
}
