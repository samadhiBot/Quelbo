//
//  FormTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class FormTests: QuelboTests {
    let factory = Factories.Form.self

    override func setUp() {
        super.setUp()

        try! Game.commit(
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("FORM"))
    }

    func testAddForm() throws {
        let symbol = try factory.init([
            .atom("+"),
            .decimal(1),
            .decimal(2),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".add(1, 2)",
            type: .int,
            children: [
                Symbol("1", type: .int, meta: [.isLiteral]),
                Symbol("2", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testLocalValueForm() throws {
        let symbol = try factory.init([
            .atom("LVAL"),
            .local("A"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol("a"))
    }

    func testNestedForms() throws {
        let symbol = try factory.init([
            .atom("SET"),
            .local("A"),
            .form([
                .atom("FORM"),
                .atom("+"),
                .decimal(1),
                .form([
                    .atom("FORM"),
                    .atom("LVAL"),
                    .local("A")
                ])
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "a.set(to: .add(1, a))",
            type: .int,
            children: [
                Symbol("a", type: .int, meta: [.mutating(true)]),
                Symbol(
                    ".add(1, a)",
                    type: .int,
                    children: [
                        Symbol("1", type: .int, meta: [.isLiteral]),
                        Symbol("a", type: .int)
                    ]
                )
            ]
        ))
    }
}
