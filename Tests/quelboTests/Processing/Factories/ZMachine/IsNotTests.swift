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

        Game.commit([
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
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".isNot(true)",
            type: .bool
        ))
    }

    func testIsNotComment() throws {
        XCTAssertThrowsError(
            try factory.init([
                .commented(
                    .string("RECOVER-STILETTO moved to DEMONS")
                )
            ], with: &registry).process()
        )
    }

    func testIsNotDirection() throws {
        var registry: Set<Symbol> = [
            Symbol(id: "north", type: .direction, category: .directions)
        ]

        let symbol = try factory.init([
            .local("NORTH")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".isNot(north)",
            type: .bool
        ))
    }

    func testIsNotInt() throws {
        let symbol = try factory.init([
            .decimal(42)
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".isNot(42)",
            type: .bool
        ))
    }

    func testIsNotObject() throws {
        let symbol = try factory.init([
            .global("SWORD")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".isNot(sword)",
            type: .bool
        ))
    }

    func testIsNotRoutine() throws {
        let symbol = try factory.init([
            .atom("TROLL-MELEE")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".isNot(trollMelee)",
            type: .bool
        ))
    }

    func testIsNotString() throws {
        let symbol = try factory.init([
            .string("Forty-two")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: #".isNot("Forty-two")"#,
            type: .bool
        ))
    }

    func testIsNotTable() throws {
        let symbol = try factory.init([
            .global("READBUF")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".isNot(readbuf)",
            type: .bool
        ))
    }

    func testIsNotThing() throws {
        var registry: Set<Symbol> = [
            Symbol(id: "prsa", type: .object),
            Symbol(id: "something", type: .thing)
        ]

        let symbol = try factory.init([
            .local("SOMETHING")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".isNot(something)",
            type: .bool
        ))
    }

    func testIsNotUnknown() throws {
        let symbol = try factory.init([
            .atom("WHAT-AM-I")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".isNot(whatAmI)",
            type: .bool
        ))
    }

    func testIsNotVoid() throws {
        let symbol = try factory.init([
            .global("THE-VOID")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".isNot(theVoid)",
            type: .bool
        ))
    }

    func testIsNotZilElement() throws {
        let symbol = try factory.init([
            .global("ZILLY")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".isNot(zilly)",
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
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".isNot([1, 2, 3])",
            type: .bool
        ))
    }

    func testIsNotOptional() throws {
        registry.insert(
            Symbol(id: "maybe", type: .optional(.object))
        )

        let symbol = try factory.init([
            .local("MAYBE")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".isNot(maybe)",
            type: .bool
        ))
    }
}
