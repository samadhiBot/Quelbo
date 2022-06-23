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
            Symbol(id: "readbuf", type: .table, category: .globals),
            Symbol(id: "sword", type: .object, category: .objects),
            Symbol(id: "theVoid", type: .void, category: .routines),
            Symbol(id: "troll", type: .object, category: .objects),
            Symbol(id: "trollMelee", type: .bool, category: .routines),
            Symbol(id: "zilly", type: .zilElement, category: .globals),
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
            type: .bool
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
            type: .bool
        ))
    }

    func testIsNotInt() throws {
        let symbol = try factory.init([
            .decimal(42)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot(42)",
            type: .bool
        ))
    }

    func testIsNotObject() throws {
        let symbol = try factory.init([
            .global("SWORD")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot(sword)",
            type: .bool
        ))
    }

    func testIsNotRoutine() throws {
        let symbol = try factory.init([
            .atom("TROLL-MELEE")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot(trollMelee)",
            type: .bool
        ))
    }

    func testIsNotString() throws {
        let symbol = try factory.init([
            .string("Forty-two")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            #".isNot("Forty-two")"#,
            type: .bool
        ))
    }

    func testIsNotTable() throws {
        let symbol = try factory.init([
            .global("READBUF")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot(readbuf)",
            type: .bool
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
            type: .bool
        ))
    }

    func testIsNotUnknown() throws {
        let symbol = try factory.init([
            .atom("WHAT-AM-I")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot(whatAmI)",
            type: .bool
        ))
    }

    func testIsNotVoid() throws {
        let symbol = try factory.init([
            .global("THE-VOID")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".isNot(theVoid)",
            type: .bool
        ))
    }

    func testIsNotZilElement() throws {
        let symbol = try factory.init([
            .global("ZILLY")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
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
            type: .bool
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
            type: .bool
        ))
    }
}
