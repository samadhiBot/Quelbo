//
//  SetTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/4/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SetTests: QuelboTests {
    let factory = Factories.Set.self

    override func setUp() {
        super.setUp()

        try! Game.commit(
            Symbol(
                "isNext",
                type: .int,
                category: .routines,
                children: [
                    Symbol("number", type: .int)
                ]
            ),
            Symbol("thirty", type: .int, category: .globals)
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("SET"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("SETG"))
    }

    func testSetToDecimal() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "foo.set(to: 3)",
            type: .int,
            children: [
                Symbol("foo", type: .int, meta: [.mutating(true)]),
                Symbol("3", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testSetToString() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .string("Bar!"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            #"foo.set(to: "Bar!")"#,
            type: .string,
            children: [
                Symbol("foo", type: .string, meta: [.mutating(true)]),
                Symbol(#""Bar!""#, type: .string, meta: [.isLiteral]),
            ]
        ))
    }

    func testSetToBool() throws {
        let symbol = try factory.init([
            .atom("ROBBED?"),
            .bool(true),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "isRobbed.set(to: true)",
            type: .bool,
            children: [
                Symbol("isRobbed", type: .bool, meta: [.mutating(true)]),
                .trueSymbol
            ]
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
            type: .int,
            children: [
                Symbol("t", type: .int, meta: [.mutating(true)]),
                Symbol(
                    "thirty.add(3)",
                    type: .int,
                    children: [
                        Symbol("thirty", type: .int, category: .globals, meta: [.mutating(true)]),
                        Symbol("3", type: .int, meta: [.isLiteral])
                    ]
                )
            ]
        ))
    }

    func testSetToLocalVariable() throws {
        let symbol = try factory.init([
            .atom("X"),
            .local("N"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "x.set(to: n)",
            type: .unknown,
            children: [
                Symbol("x", type: .variable(.unknown), meta: [.mutating(true)]),
                Symbol("n", type: .unknown),
            ]
        ))
    }

    func testSetToFunctionResult() throws {
        let symbol = try factory.init([
            .atom("N"),
            .form([
                .atom("NEXT?"),
                .local("X")
            ]),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "n.set(to: isNext(number: x))",
            type: .int,
            children: [
                Symbol("n", type: .int, meta: [.mutating(true)]),
                Symbol(
                    "isNext(number: x)",
                    type: .int,
                    children: [
                        Symbol(id: "number", code: "number: x", type: .int)
                    ]
                )
            ]
        ))
    }

    func testSetToModifiedSelf() throws {
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
            type: .int,
            children: [
                Symbol("n", type: .int, meta: [.mutating(true)]),
                Symbol(
                    "n.subtract(1)",
                    type: .int,
                    children: [
                        Symbol("n", type: .int, meta: [.mutating(true)]),
                        Symbol("1", type: .int, meta: [.isLiteral]),
                    ]
                )
            ]
        ))
    }

    func testSetWithoutAName() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .decimal(3),
            ]).process()
        )
    }
}
