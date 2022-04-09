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
                Symbol("foo", type: .int),
                Symbol("3", type: .int),
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
                Symbol("foo", type: .string),
                Symbol(#""Bar!""#, type: .string),
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
                Symbol("isRobbed", type: .bool),
                Symbol("true", type: .bool),
            ]
        ))
    }

    func testSetVariableCalledT() throws {
        let symbol = try factory.init([
            .atom("T"),
            .form([
                .atom("ADD"),
                .atom(",THIRTY"),
                .atom("3"),
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "t.set(to: thirty.add(3))",
            type: .int,
            children: [
                Symbol("t", type: .int),
                Symbol(
                    "thirty.add(3)",
                    type: .int,
                    children: [
                        Symbol("thirty", type: .int, category: .globals),
                        Symbol("3", type: .int)
                    ]
                )
            ]
        ))
    }

    func testSetToLocalVariable() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("X"),
                .atom(".N"),
            ]).process()
        )
    }

    func testSetToFunctionResult() throws {
        let symbol = try factory.init([
            .atom("N"),
            .form([
                .atom("NEXT?"),
                .atom(".X")
            ]),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "n.set(to: isNext(number: x))",
            type: .int,
            children: [
                Symbol("n", type: .int),
                Symbol(
                    id: "isNext",
                    code: "isNext(number: x)",
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
                .atom(".N"),
                .decimal(1)
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "n.set(to: n.subtract(1))",
            type: .int,
            children: [
                Symbol("n", type: .int),
                Symbol(
                    "n.subtract(1)",
                    type: .int,
                    children: [
                        Symbol("n", type: .int),
                        Symbol("1", type: .int),
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
