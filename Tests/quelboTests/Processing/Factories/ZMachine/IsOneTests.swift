//
//  IsOneTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsOneTests: QuelboTests {
    let factory = Factories.IsOne.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol("foo", type: .int, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("1?"))
    }

    func testIsOne() throws {
        let symbol = try factory.init([
            .decimal(2)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "2.isOne",
            type: .bool,
            children: [
                Symbol("2", type: .int)
            ]
        ))
    }

    func testIsOneGlobal() throws {
        let symbol = try factory.init([
            .atom(",FOO")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "foo.isOne",
            type: .bool,
            children: [
                Symbol("foo", type: .int, category: .globals)
            ]
        ))
    }

    func testIsOneLocal() throws {
        let symbol = try factory.init([
            .atom(".BAR")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "bar.isOne",
            type: .bool,
            children: [
                Symbol("bar", type: .int)
            ]
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
