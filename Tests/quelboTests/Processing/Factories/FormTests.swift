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

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("FORM"))
    }

    func testForm() throws {
        let symbol = try factory.init([
            .atom("+"),
            .decimal(1),
            .decimal(2),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".add(1, 2)",
            type: .int
        ))
    }

    func testNestedForms() throws {
        localVariables.append(
            Variable(id: "a", type: .int)
        )

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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "a.set(to: .add(1, a))",
            type: .int
        ))
    }
}
