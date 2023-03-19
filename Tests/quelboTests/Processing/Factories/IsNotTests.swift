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

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("NOT"))
    }

    func testIsNotBool() throws {
        let symbol = process("<NOT T>")

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(true)",
            type: .bool
        ))
    }

    func testIsNotDirection() throws {
        let symbol = process("""
            <DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT>

            <NOT NORTH>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(north)",
            type: .bool
        ))
    }

    func testIsNotInt() throws {
        let symbol = process("<NOT 42>")

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(42)",
            type: .bool
        ))
    }

    func testIsNotObject() throws {
        let symbol = process("<NOT SWORD>")

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(sword)",
            type: .bool
        ))
    }

    func testIsNotRoutine() throws {
        let symbol = process("<NOT TROLL-MELEE>")

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(trollMelee)",
            type: .bool
        ))
    }

    func testIsNotString() throws {
        let symbol = process("""
            <NOT "Forty-two">
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: #".isNot("Forty-two")"#,
            type: .bool
        ))
    }

    func testIsNotTable() throws {
        let symbol = process("""
            <GLOBAL READBUF <TABLE 0 1 2>>

            <NOT ,READBUF>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(Globals.readbuf)",
            type: .bool
        ))
    }

    func testIsNotThing() throws {
        let symbol = process("""
            <THING SOMETHING>

            <NOT SOMETHING>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(something)",
            type: .bool
        ))
    }

    func testIsNotUnknown() throws {
        let symbol = process("<NOT WHAT-AM-I>")

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(whatAmI)",
            type: .bool
        ))
    }

    func testIsNotVoid() throws {
        let symbol = process("""
            <ROUTINE THE-VOID>

            <NOT THE-VOID>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(Routines.theVoid)",
            type: .bool
        ))
    }

    func testIsNotTableElement() throws {
        let symbol = process("""
            <GLOBAL SILLY <TABLE "Zilly">>

            <NOT <GET ,SILLY 0>>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: ".isNot(try Globals.silly.get(at: 0))",
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
            Statement(id: "maybe", type: .object.optional)
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
