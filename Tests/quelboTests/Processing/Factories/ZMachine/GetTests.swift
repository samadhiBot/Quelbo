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
    }

    func testGet() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .decimal(2)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                let foo: [TableElement] = [
                    .room(forest1),
                    .room(forest2),
                    .room(forest3),
                ][2]
                """,
            type: .tableElement,
            children: [
                fooTable,
                Symbol("2", type: .int)
            ]
        ))
    }

    func testThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("FOO"),
                .decimal(2)
            ]).process()
        )
    }
}
