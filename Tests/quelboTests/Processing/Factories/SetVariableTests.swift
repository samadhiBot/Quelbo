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
            type: .int,
            confidence: .certain
        ))
    }

    func testSetVariableToString() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .string("Bar!"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"foo.set(to: "Bar!")"#,
            type: .string,
            confidence: .certain
        ))
    }

    func testSetVariableToBool() throws {
        let symbol = try factory.init([
            .atom("ROBBED?"),
            .bool(true),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "isRobbed.set(to: true)",
            type: .bool,
            confidence: .booleanTrue
        ))
    }

    func testSetVariableCalledT() throws {
        localVariables.append(Variable(id: "t"))

        let symbol = try factory.init([
            .atom("T"),
            .form([
                .atom("ADD"),
                .global("THIRTY"),
                .decimal(3),
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "t.set(to: thirty.add(3))",
            type: .int,
            confidence: .certain
        ))
    }

    func testSetVariableToLocalVariable() throws {
        localVariables.append(
            Variable(id: "n", type: .string)
//            Variable(id: "n", code: "var n: String = \"Foo!\"", type: .string)
        )

        let symbol = try factory.init([
            .atom("X"),
            .local("N"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "x.set(to: n)",
            type: .string,
            confidence: .certain
        ))
    }

    func testSetVariableToFunctionResult() throws {
        localVariables.append(
            Variable(id: "x", type: .object)
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
            type: .object,
            confidence: .certain
        ))
    }

    func testSetVariableToModifiedSelf() throws {
        localVariables.append(
            Variable(id: "n", type: .int)
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
            code: "n.set(to: n.subtract(1))",
            type: .int,
            confidence: .certain
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
