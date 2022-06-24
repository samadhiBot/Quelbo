//
//  IsZeroTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsZeroTests: QuelboTests {
    let factory = Factories.IsZero.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol(id: "foo", type: .int, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("0?"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("ZERO?"))
    }

    func testIsZero() throws {
        let symbol = try factory.init([
            .decimal(2)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.isZero",
            type: .bool
        ))
    }

    func testIsZeroGlobal() throws {
        let symbol = try factory.init([
            .global("FOO")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "foo.isZero",
            type: .bool
        ))
    }

    func testIsZeroLocal() throws {
        let symbol = try factory.init([
            .local("BAR")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "bar.isZero",
            type: .bool
        ))
    }

    func testThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("2")
            ]).process()
        )
    }
}
