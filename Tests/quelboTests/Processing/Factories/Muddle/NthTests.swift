//
//  NthTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class NthTests: QuelboTests {
    let factory = Factories.Nth.self

    override func setUp() {
        super.setUp()

        try! Game.commit(
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("NTH"))
    }

    func testNthElementInVector() throws {
        let symbol = try factory.init([
            .form([
                .atom("VECTOR"),
                .string("AB"),
                .string("CD"),
                .string("EF")
            ]),
            .decimal(2)
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            #"["AB", "CD", "EF"].nthElement(2)"#,
            type: .string,
            children: [
                Symbol(
                    id: "[\"AB\", \"CD\", \"EF\"]",
                    code: "[\"AB\", \"CD\", \"EF\"]",
                    type: .array(.string),
                    children: [
                        Symbol("\"AB\"", type: .string, meta: [.isLiteral]),
                        Symbol("\"CD\"", type: .string, meta: [.isLiteral]),
                        Symbol("\"EF\"", type: .string, meta: [.isLiteral])
                    ]
                ),
                Symbol("2", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testShortHandCall() throws {
        let symbol = try Factories.Set.init([
            .atom("A"),
            .form([
                .decimal(3),
                .form([
                    .atom("VECTOR"),
                    .string("AB"),
                    .string("CD"),
                    .string("EF")
                ])
            ])
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            #"a.set(to: ["AB", "CD", "EF"].nthElement(3))"#,
            type: .string,
            children: [
                Symbol("a", type: .string, meta: [.mutating(true)]),
                Symbol(
                    "[\"AB\", \"CD\", \"EF\"].nthElement(3)",
                    type: .string,
                    children: [
                        Symbol(
                            "[\"AB\", \"CD\", \"EF\"]",
                            type: .array(.string),
                            children: [
                                Symbol("\"AB\"", type: .string, meta: [.isLiteral]),
                                Symbol("\"CD\"", type: .string, meta: [.isLiteral]),
                                Symbol("\"EF\"", type: .string, meta: [.isLiteral])
                            ]
                        ),
                        Symbol("3", type: .int, meta: [.isLiteral])
                    ]
                )
            ]
        ))
    }
}
