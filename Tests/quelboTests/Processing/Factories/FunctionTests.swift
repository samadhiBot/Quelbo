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

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("FUNCTION"))
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                {
                    var x: Int = 1
                    var y: Int = 2
                    return x.add(y)
                }
                """,
            type: .function([], .int),
            isMutable: false
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                { (n: Int) -> Int in
                    var n: Int = n
                    return n.multiply(n)
                }
                """,
            type: .function([.int], .int),
            isMutable: false
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                { (a: Int, b: Int) -> Int in
                    var a: Int = a
                    return a.add(b)
                }
                """,
            type: .function([.int, .int], .int),
            isMutable: false
        ))
    }
}
