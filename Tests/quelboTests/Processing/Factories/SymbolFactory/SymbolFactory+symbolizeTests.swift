//
//  SymbolFactory+symbolizeTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/31/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SymbolFactorySymbolizeTests: QuelboTests {
    let testFactory = TestFactory.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol(id: "inc", type: .int, category: .routines),
            Symbol(id: "boardedWindow", type: .object, category: .globals),
            Symbol(id: "north", type: .direction, category: .properties),
        ])
    }

    func testSymbolizeAtom() throws {
        let symbol = try testFactory.init([
            .atom("BOARDED-WINDOW")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "boardedWindow",
            code: "boardedWindow",
            type: .object,
            category: .globals
        ))
    }

    func testSymbolizeBoolTrue() throws {
        let symbol = try testFactory.init([
            .bool(true)
        ]).process()

        XCTAssertNoDifference(symbol, .trueSymbol)
    }

    func testSymbolizeBoolFalse() throws {
        let symbol = try testFactory.init([
            .bool(false)
        ]).process()

        XCTAssertNoDifference(symbol, .falseSymbol)
    }

    func testSymbolizeCharacter() throws {
        let symbol = try testFactory.init([
            .character("Z")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "Z".quoted,
            type: .string,
            meta: [.isLiteral]
        ))
    }

    func testSymbolizeCommented() throws {
        let symbol = try testFactory.init([
            .commented(.bool(true))
        ]).process()

        XCTAssertNoDifference(symbol, Symbol("/* true */", type: .comment))
    }

    func testSymbolizeDecimal() throws {
        let symbol = try testFactory.init([
            .decimal(42)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol("42", type: .int, meta: [.isLiteral]))
    }

    func testSymbolizeEval() throws {
        let symbol = try testFactory.init([
            .eval(
                .form([
                    .atom("+"),
                    .decimal(2),
                    .decimal(3),
                ])
            )
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".add(2, 3)",
            type: .int
        ))
    }

    func testSymbolizeGlobal() throws {
        let symbol = try testFactory.init([
            .global("BOARDED-WINDOW")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "boardedWindow",
            code: "boardedWindow",
            type: .object,
            category: .globals
        ))
    }

    func testSymbolizeList() throws {
        let symbol = try testFactory.init([
            .list([
                .atom("FLOATING?"),
                .bool(false),
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "[isFloating, false]",
            type: .array(.bool)
        ))
    }

    func testSymbolizeLocal() throws {
        let symbol = try testFactory.init([
            .local("FOO-BAR")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(id: "fooBar", code: "fooBar"))
    }

    func testSymbolizeProperty() throws {
        let symbol = try testFactory.init([
            .property("STRENGTH")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "strength",
            type: .int,
            category: .properties
        ))
    }

    func testSymbolizePropertyDirection() throws {
        let symbol = try testFactory.init([
            .property("NORTH")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "north",
            code: "north",
            type: .direction,
            category: .directions
        ))
    }

    func testSymbolizeQuote() throws {
        let symbol = try testFactory.init([
            .quote(.form([
                .atom("RANDOM"),
                .decimal(100)
            ]))
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".random(100)",
            type: .int
        ))
    }

    func testSymbolizeSegment() throws {
        let symbol = try testFactory.init([
            .segment(
                .form([
                    .atom("+"),
                    .decimal(2),
                    .decimal(3),
                ])
            )
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            ".add(2, 3)",
            type: .int
        ))
    }

    func testSymbolizeString() throws {
        let symbol = try testFactory.init([
            .string("Plants can talk")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            #""Plants can talk""#,
            type: .string,
            meta: [.isLiteral]
        ))
    }

    func testSymbolizeTypeByte() throws {
        let symbol = try testFactory.init([
            .type("BYTE"),
            .decimal(42),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "42",
            type: .int8,
            meta: [.isLiteral]
        ))
    }
}
