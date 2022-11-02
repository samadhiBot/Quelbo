//
//  SetVariableTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/4/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SetVariableTests: QuelboTests {
    let factory = Factories.SetVariable.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "thirty", type: .int, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("SET"))
    }

    func testSetVariableToDecimal() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .decimal(3),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "foo.set(to: 3)",
            type: .int
        ))
    }

    func testSetVariableToString() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .string("Bar!"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"foo.set(to: "Bar!")"#,
            type: .string
        ))
    }

    func testSetVariableToBool() throws {
        let symbol = try factory.init([
            .atom("ROBBED?"),
            .bool(true),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "isRobbed.set(to: true)",
            type: .booleanTrue
        ))
    }

    func testSetVariableCalledT() throws {
        localVariables.append(.init(id: "t", type: .int))

        let symbol = try factory.init([
            .atom("T"),
            .form([
                .atom("ADD"),
                .global(.atom("THIRTY")),
                .decimal(3),
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "t.set(to: .add(thirty, 3))",
            type: .int
        ))
    }

    func testSetVariableToLocalVariable() throws {
        localVariables.append(
            Statement(id: "n", type: .string)
        )

        let symbol = try factory.init([
            .atom("X"),
            .local("N"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "x.set(to: n)",
            type: .string
        ))
    }

    func testSetVariableToFunctionResult() throws {
        localVariables.append(
            Statement(id: "x", type: .object)
        )

        let symbol = try factory.init([
            .atom("N"),
            .form([
                .atom("NEXT?"),
                .local("X")
            ]),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "n.set(to: x.nextSibling)",
            type: .object
        ))
    }

    func testSetVariableToModifiedSelf() throws {
        localVariables.append(
            Statement(id: "n", type: .int)
        )

        let symbol = try factory.init([
            .atom("N"),
            .form([
                .atom("-"),
                .local("N"),
                .decimal(1)
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "n.set(to: .subtract(n, 1))",
            type: .int
        ))
    }

    func testSetVariableWithoutAName() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .decimal(3),
            ], with: &localVariables).process()
        )
    }
}