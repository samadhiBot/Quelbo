//
//  SetLocalTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/4/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SetLocalTests: QuelboTests {
    let factory = Factories.SetLocal.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("SET"))
    }

    func testSetLocalToDecimal() throws {
        let symbol = process("""
            <SET FOO 3>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: "foo.set(to: 3)",
            type: .int
        ))
    }

    func testSetLocalToString() throws {
        let symbol = process("""
            <SET FOO "Bar!">
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: #"foo.set(to: "Bar!")"#,
            type: .string
        ))
    }

    func testSetLocalToBool() throws {
        let symbol = process("""
            <SET ROBBED? T>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: "isRobbed.set(to: true)",
            type: .booleanTrue
        ))
    }

    func testSetLocalCalledT() throws {
        let symbol = process("""
            <SET T <ADD THIRTY 3>>
        """, with: [
            Statement(id: "t", type: .int)
        ])

        XCTAssertNoDifference(symbol, .statement(
            code: "t.set(to: .add(thirty, 3))",
            type: .int
        ))
    }

    func testSetLocalToLocalVariable() throws {
        let symbol = process("""
            <SET X N>
        """, with: [
            Statement(id: "n", type: .string)
        ])

        XCTAssertNoDifference(symbol, .statement(
            code: "x.set(to: n)",
            type: .string
        ))
    }

    func testSetLocalToFunctionResult() throws {
        let symbol = process("""
            <SET N <NEXT? X>>
        """, with: [
            Statement(id: "x", type: .object)
        ])

        XCTAssertNoDifference(symbol, .statement(
            code: "n.set(to: x.nextSibling)",
            type: .object
        ))
    }

    func testSetLocalToModifiedSelf() throws {
        let symbol = process("""
            <SET N <- N 1>>
        """, with: [
            Statement(id: "n", type: .int)
        ])

        XCTAssertNoDifference(symbol, .statement(
            code: "n.set(to: .subtract(n, 1))",
            type: .int
        ))
    }

    func testSetLocalWithoutAName() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .decimal(3),
            ], with: &localVariables).process()
        )
    }
}
