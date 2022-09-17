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
            .variable(id: "readbuf", type: .table, category: .globals),
            .variable(id: "sword", type: .object, category: .objects),
            .variable(id: "theVoid", type: .void, category: .routines),
            .variable(id: "troll", type: .object, category: .objects),
            .variable(id: "trollMelee", type: .bool, category: .routines),
            .variable(id: "zilly", type: .zilElement, category: .globals),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("NOT"))
    }

    func testIsNotBool() throws {
        let symbol = try factory.init([
            .bool(true)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(true)",
            type: .bool
        ))
    }

    func testIsNotDirection() throws {
        localVariables.append(
            Variable(id: "north", type: .direction, category: .directions)
        )

        let symbol = try factory.init([
            .local("NORTH")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(north)",
            type: .bool
        ))
    }

    func testIsNotInt() throws {
        let symbol = try factory.init([
            .decimal(42)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(42)",
            type: .bool
        ))
    }

    func testIsNotObject() throws {
        let symbol = try factory.init([
            .global("SWORD")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(sword)",
            type: .bool
        ))
    }

    func testIsNotRoutine() throws {
        let symbol = try factory.init([
            .atom("TROLL-MELEE")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(trollMelee)",
            type: .bool
        ))
    }

    func testIsNotString() throws {
        let symbol = try factory.init([
            .string("Forty-two")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #".isNot("Forty-two")"#,
            type: .bool
        ))
    }

    func testIsNotTable() throws {
        let symbol = try factory.init([
            .global("READBUF")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(readbuf)",
            type: .bool
        ))
    }

    func testIsNotThing() throws {
        localVariables.append(contentsOf: [
            Variable(id: "prsa", type: .object),
            Variable(id: "something", type: .thing),
        ])

        let symbol = try factory.init([
            .local("SOMETHING")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(something)",
            type: .bool
        ))
    }

    func testIsNotUnknown() throws {
        let symbol = try factory.init([
            .atom("WHAT-AM-I")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(whatAmI)",
            type: .bool
        ))
    }

    func testIsNotVoid() throws {
        let symbol = try factory.init([
            .global("THE-VOID")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(theVoid)",
            type: .bool
        ))
    }

    func testIsNotZilElement() throws {
        let symbol = try factory.init([
            .global("ZILLY")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot([1, 2, 3])",
            type: .bool
        ))
    }

    func testIsNotOptional() throws {
        localVariables.append(
            Variable(id: "maybe", type: .optional(.object))
        )

        let symbol = try factory.init([
            .local("MAYBE")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(maybe)",
            type: .bool
        ))
    }
}
