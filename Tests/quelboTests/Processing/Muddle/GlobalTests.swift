//
//  GlobalTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/8/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GlobalTests: XCTestCase {
    func testAtom() throws {
        var global = Global([
            .atom("FOO"),
            .atom("unexpected")
        ], isMutable: true)
        XCTAssertThrowsError(try global.process())
    }

    func testBool() throws {
        var global = Global([
            .atom("FOO"),
            .bool(true)
        ], isMutable: true)
        XCTAssertNoDifference(
            try global.process().code,
            "var foo: Bool = true"
        )
    }

    func testCommented() throws {
        var global = Global([
            .atom("FOO"),
            .commented(.string("BAR"))
        ], isMutable: true)
        XCTAssertThrowsError(try global.process())
    }

    func testDecimal() throws {
        var global = Global([
            .atom("FOO"),
            .decimal(42)
        ], isMutable: true)
        XCTAssertNoDifference(
            try global.process().code,
            "var foo: Int = 42"
        )
    }

    func testForm() throws {
        var global = Global([
            .atom("FOO"),
            .form([
                .atom("TABLE"),
                .atom("FOREST-1"),
                .atom("FOREST-2"),
                .atom("FOREST-3"),
            ])
        ], isMutable: true)
        XCTAssertNoDifference(
            try global.process().code,
            """
            var foo = ZIL.Table(
                .atom("FOREST-1"),
                .atom("FOREST-2"),
                .atom("FOREST-3"),
            )
            """
        )
    }

    func testList() throws {
        var global = Global([
            .atom("FOO"),
            .list([.string("BAR")])
        ], isMutable: true)
        XCTAssertThrowsError(try global.process())
    }

    func testQuoted() throws {
        var global = Global([
            .atom("FOO"),
            .quoted(.string("BAR"))
        ], isMutable: true)
        XCTAssertThrowsError(try global.process())
    }

    func testString() throws {
        var global = Global([
            .atom("FOO"),
            .string("Forty Two!")
        ], isMutable: true)
        XCTAssertNoDifference(
            try global.process().code,
            #"var foo: String = "Forty Two!""#
        )
    }

    // MARK: - Constants

    func testAtomConstant() throws {
        var global = Global([
            .atom("FOO"),
            .atom("unexpected")
        ])
        XCTAssertThrowsError(try global.process())
    }

    func testBoolConstant() throws {
        var global = Global([
            .atom("FOO"),
            .bool(true)
        ])
        XCTAssertNoDifference(
            try global.process().code,
            "let foo: Bool = true"
        )
    }

    func testCommentedConstant() throws {
        var global = Global([
            .atom("FOO"),
            .commented(.string("BAR"))
        ])
        XCTAssertThrowsError(try global.process())
    }

    func testDecimalConstant() throws {
        var global = Global([
            .atom("FOO"),
            .decimal(42)
        ])
        XCTAssertNoDifference(
            try global.process().code,
            "let foo: Int = 42"
        )
    }

    func testFormConstant() throws {
        var global = Global([
            .atom("FOO"),
            .form([
                .atom("TABLE"),
                .atom("FOREST-1"),
                .atom("FOREST-2"),
                .atom("FOREST-3"),
            ])
        ])
        XCTAssertNoDifference(
            try global.process().code,
            """
            let foo = ZIL.Table(
                .atom("FOREST-1"),
                .atom("FOREST-2"),
                .atom("FOREST-3"),
            )
            """
        )
    }

    func testListConstant() throws {
        var global = Global([
            .atom("FOO"),
            .list([.string("BAR")])
        ])
        XCTAssertThrowsError(try global.process())
    }

    func testQuotedConstant() throws {
        var global = Global([
            .atom("FOO"),
            .quoted(.string("BAR"))
        ])
        XCTAssertThrowsError(try global.process())
    }

    func testStringConstant() throws {
        var global = Global([
            .atom("FOO"),
            .string("Forty Two!")
        ])
        XCTAssertNoDifference(
            try global.process().code,
            #"let foo: String = "Forty Two!""#
        )
    }

}
