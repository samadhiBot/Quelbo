//
//  SymbolFactoryTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/31/22.
//

import CustomDump
import XCTest
@testable import quelbo

class TestFactory: SymbolFactory {
    override func process() throws -> Symbol {
        let symbols = try symbolize(tokens)
        return symbols[0]
    }
}

final class SymbolFactoryTests: QuelboTests {
    let testFactory = TestFactory.self

    override func setUp() {
        super.setUp()

        try! Game.commit(
            Symbol("boardedWindow", type: .object, category: .globals)
        )
    }

    func testSymbolizeAtom() throws {
        let symbol = try testFactory.init([
            .atom("BOARDED-WINDOW")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol("boardedWindow", type: .object, category: .globals))
    }

    func testSymbolizeGlobalAtom() throws {
        let symbol = try testFactory.init([
            .atom(",BOARDED-WINDOW")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "boardedWindow",
            type: .object,
            category: .globals
        ))
    }

    func testSymbolizeBoolTrue() throws {
        let symbol = try testFactory.init([
            .bool(true)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol("true", type: .bool, literal: symbol.literal))
    }

    func testSymbolizeBoolFalse() throws {
        let symbol = try testFactory.init([
            .bool(false)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol("false", type: .bool, literal: symbol.literal))
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

        XCTAssertNoDifference(symbol, Symbol("42", type: .int, literal: true))
    }

    func testSymbolizeList() throws {
        let symbol = try testFactory.init([
            .list([
                .atom("FLOATING?"),
                .bool(false),
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<List>",
            code: "",
            type: .list,
            children: [
                Symbol("isFloating", type: .bool),
                .falseSymbol
            ]
        ))
    }

    func testSymbolizeQuoted() throws {
        let symbol = try testFactory.init([
            .quoted(.bool(true))
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(#"/* true */"#, type: .comment))
    }

    func testSymbolizeString() throws {
        let symbol = try testFactory.init([
            .string("Plants can talk")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            #""Plants can talk""#,
            type: .string,
            literal: symbol.literal
        ))
    }
}
