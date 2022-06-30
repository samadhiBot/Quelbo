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

        Game.commit(
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
            code: ".add(1, 2)",
            type: .int
        ))
    }

    func testLocalValueForm() throws {
        let symbol = try factory.init([
            .atom("LVAL"),
            .local("A"),
        ], with: [
            Symbol(id: "a", type: .variable(.string))
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "a",
            code: "a",
            type: .variable(.string)
        ))
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
        ], with: [
            Symbol(id: "a", type: .variable(.int))
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "a.set(to: .add(1, a))",
            type: .int
        ))
    }
}
