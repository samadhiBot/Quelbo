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

        try! Game.commit(
            Symbol(
                id: "isNext",
                type: .int,
                category: .routines,
                children: [
                    Symbol("number", type: .int)
                ]
            ),
            Symbol(id: "thirty", type: .int, category: .globals)
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("SET"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("SETG"))
    }

    func testSetVariableToDecimal() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "foo.set(to: 3)",
            type: .int
        ))
    }

    func testSetVariableToString() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .string("Bar!"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            #"foo.set(to: "Bar!")"#,
            type: .string
        ))
    }

    func testSetVariableToBool() throws {
        let symbol = try factory.init([
            .atom("ROBBED?"),
            .bool(true),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "isRobbed.set(to: true)",
            type: .bool
        ))
    }

    func testSetVariableCalledT() throws {
        let symbol = try factory.init([
            .atom("T"),
            .form([
                .atom("ADD"),
                .global("THIRTY"),
                .decimal(3),
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "t.set(to: thirty.add(3))",
            type: .int
        ))
    }

    func testSetVariableToLocalVariable() throws {
        let registry = SymbolRegistry([
            Symbol(id: "n", code: "var n: String = \"Foo!\"", type: .string),
        ])

        let symbol = try factory.init([
            .atom("X"),
            .local("N"),
        ], with: registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            "x.set(to: n)",
            type: .string
        ))
    }

    func testSetVariableToFunctionResult() throws {
        let symbol = try factory.init([
            .atom("N"),
            .form([
                .atom("NEXT?"),
                .local("X")
            ]),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "n.set(to: x.nextSibling)",
            type: .object
        ))
    }

    func testSetVariableToModifiedSelf() throws {
        let symbol = try factory.init([
            .atom("N"),
            .form([
                .atom("-"),
                .local("N"),
                .decimal(1)
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "n.set(to: n.subtract(1))",
            type: .int
        ))
    }

    func testSetVariableWithoutAName() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .decimal(3),
            ]).process()
        )
    }
}
