//
//  FunctionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class FunctionTests: QuelboTests {
    let factory = Factories.Function.self

    override func setUp() {
        super.setUp()

        Game.commit(
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("FUNCTION"))
    }

    func testSimpleAddFunction() throws {
        let symbol = try factory.init([
            .list([
                .string("AUX"),
                .list([
                    .atom("X"),
                    .decimal(1)
                ]),
                .list([
                    .atom("Y"),
                    .decimal(2)
                ])
            ]),
            .form([
                .atom("+"),
                .local("X"),
                .local("Y")
            ])
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: """
                {
                    var x: Int = 1
                    var y: Int = 2
                    return x.add(y)
                }
                """,
            type: .int,
            meta: [
                .isImmutable,
                .type("() -> Int"),
            ]
        ))
    }

    func testFunctionWithSingleParam() throws {
        let symbol = try factory.init([
            .list([
                .atom("N")
            ]),
            .form([
                .atom("*"),
                .local("N"),
                .local("N")
            ])
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: """
                { (n: Int) -> Int in
                    var n = n
                    return n.multiply(n)
                }
                """,
            type: .int,
            meta: [
                .isImmutable,
                .type("(Int) -> Int"),
            ]
        ))
    }

    func testFunctionWithTwoParams() throws {
        let symbol = try factory.init([
            .list([
                .atom("A"),
                .atom("B"),
            ]),
            .form([
                .atom("+"),
                .local("A"),
                .local("B")
            ])
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: """
                { (a: Int, b: Int) -> Int in
                    var a = a
                    return a.add(b)
                }
                """,
            type: .int,
            meta: [
                .isImmutable,
                .type("(Int, Int) -> Int"),
            ]
        ))
    }
}
