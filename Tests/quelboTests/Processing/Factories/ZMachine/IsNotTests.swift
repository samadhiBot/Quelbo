//
//  IsNotTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsNotTests: QuelboTests {
    let factory = Factories.IsNot.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol("readbuf", type: .table, category: .globals),
            Symbol("sword", type: .object, category: .objects),
            Symbol("theVoid", type: .void, category: .routines),
            Symbol("troll", type: .object, category: .objects),
            Symbol("trollMelee", type: .bool, category: .routines),
            Symbol("zilly", type: .zilElement, category: .globals),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("NOT"))
    }

    func testIsNotBool() throws {
        let symbol = try factory.init([
            .bool(true)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot(true)",
            type: .bool,
            children: [.trueSymbol]
        ))
    }

    func testIsNotComment() throws {
        XCTAssertThrowsError(
            try factory.init([
                .commented(
                    .string("RECOVER-STILETTO moved to DEMONS")
                )
            ]).process()
        )
    }

    func testIsNotDirection() throws {
        let registry = SymbolRegistry([
            Symbol("north", type: .direction, category: .directions)
        ])

        let symbol = try factory.init([
            .local("NORTH")
        ], with: registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot(north)",
            type: .bool,
            children: [
                Symbol("north", type: .direction, category: .directions),
            ]
        ))
    }

    func testIsNotInt() throws {
        let symbol = try factory.init([
            .decimal(42)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot(42)",
            type: .bool,
            children: [
                Symbol("42", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testIsNotObject() throws {
        let symbol = try factory.init([
            .global("SWORD")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot(sword)",
            type: .bool,
            children: [
                Symbol("sword", type: .object, category: .objects),
            ]
        ))
    }

    func testIsNotRoutine() throws {
        let symbol = try factory.init([
            .atom("TROLL-MELEE")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot(trollMelee)",
            type: .bool,
            children: [
                Symbol("trollMelee", type: .bool, category: .routines),
            ]
        ))
    }

    func testIsNotString() throws {
        let symbol = try factory.init([
            .string("Forty-two")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            #".isNot("Forty-two")"#,
            type: .bool,
            children: [
                Symbol("Forty-two".quoted, type: .string, meta: [.isLiteral])
            ]
        ))
    }

    func testIsNotTable() throws {
        let symbol = try factory.init([
            .global("READBUF")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot(readbuf)",
            type: .bool,
            children: [
                Symbol("readbuf", type: .table, category: .globals),
            ]
        ))
    }

    func testIsNotThing() throws {
        let registry = SymbolRegistry([
            Symbol("something", type: .thing)
        ])

        let symbol = try factory.init([
            .local("SOMETHING")
        ], with: registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot(something)",
            type: .bool,
            children: [
                Symbol("something", type: .thing)
            ]
        ))
    }

    func testIsNotUnknown() throws {
        let symbol = try factory.init([
            .atom("WHAT-AM-I")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot(whatAmI)",
            type: .bool,
            children: [
                Symbol("whatAmI")
            ]
        ))
    }

    func testIsNotVoid() throws {
        let symbol = try factory.init([
            .global("THE-VOID")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot(theVoid)",
            type: .bool,
            children: [
                Symbol("theVoid", type: .void, category: .routines),
            ]
        ))
    }

    func testIsNotZilElement() throws {
        let symbol = try factory.init([
            .global("ZILLY")
        ]).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            ".isNot(zilly)",
            type: .bool
        ))
    }

    func testIsNotArray() throws {
        let symbol = try factory.init([
            .list([
                .decimal(1),
                .decimal(2),
                .decimal(3),
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot([1, 2, 3])",
            type: .bool,
            children: [
                Symbol(
                    "[1, 2, 3]",
                    type: .array(.int),
                    children: [
                        .intSymbol(1),
                        .intSymbol(2),
                        .intSymbol(3),
                    ]
                )
            ]
        ))
    }

    func testIsNotOptional() throws {
        let registry = SymbolRegistry([
            Symbol("maybe", type: .optional(.object))
        ])

        let symbol = try factory.init([
            .local("MAYBE")
        ], with: registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot(maybe)",
            type: .bool,
            children: [
                Symbol("maybe", type: .optional(.object))
            ]
        ))
    }
}
