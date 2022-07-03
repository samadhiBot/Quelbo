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

        Game.commit([
            Symbol(id: "foo", type: .int, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("1?"))
    }

    func testIsOne() throws {
        let symbol = try factory.init([
            .decimal(2)
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "2.isOne",
            type: .bool
        ))
    }

    func testIsOneGlobal() throws {
        let symbol = try factory.init([
            .global("FOO")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "foo.isOne",
            type: .bool
        ))
    }

    func testIsOneLocal() throws {
        registry.append(
            Symbol(id: "bar", type: .variable(.int))
        )

        let symbol = try factory.init([
            .local("BAR")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "bar.isOne",
            type: .bool
        ))
    }

    func testThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("2")
            ], with: &registry).process()
        )
    }
}
