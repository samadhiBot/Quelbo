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

    func testUselessAddFunctionWithoutParams() throws {
        let symbol = process("""
            <FUNCTION ("AUX" (X 1) (Y 2)) <+ .X .Y>>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "anone836",
            code: """
                func anone836() -> Int {
                    var x: Int = 1
                    var y: Int = 2
                    return .add(x, y)
                }
                """,
            type: .int,
            isMutable: false
        ))
    }

    func testFunctionWithSingleParam() throws {
        let symbol = process("""
            <FUNCTION (N) <* .N .N>>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "anon8fd9",
            code: """
                func anon8fd9(n: Int) -> Int {
                    return .multiply(n, n)
                }
                """,
            type: .int,
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
            id: "anonea8b",
            code: """
                func anonea8b(a: Int, b: Int) -> Int {
                    return .add(a, b)
                }
                """,
            type: .int,
            isMutable: false
        ))
    }
}
