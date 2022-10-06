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
            id: "anon247a",
            code: """
                func anon247a() -> Int {
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
            id: "anon87f2",
            code: """
                func anon87f2(n: Int) -> Int {
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
            id: "anonf70d",
            code: """
                func anonf70d(a: Int, b: Int) -> Int {
                    return .add(a, b)
                }
                """,
            type: .int,
            isMutable: false
        ))
    }
}
