//
//  PutTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/1/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PutTests: QuelboTests {
    let factory = Factories.Put.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol("mytable", type: .table, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PUT"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PUTB"))
    }

    func testPutInteger() throws {
        let symbol = try factory.init([
            .global("MYTABLE"),
            .decimal(1),
            .decimal(123)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "try mytable.put(element: 123, at: 1)",
            type: .int,
            children: [
                Symbol("mytable", type: .table, category: .globals),
                Symbol("1", type: .int, meta: [.isLiteral]),
                Symbol("123", type: .int, meta: [.isLiteral]),
            ]
        ))
    }

    func testPutString() throws {
        let symbol = try factory.init([
            .global("MYTABLE"),
            .decimal(1),
            .string("hello")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            #"try mytable.put(element: "hello", at: 1)"#,
            type: .string,
            children: [
                Symbol("mytable", type: .table, category: .globals),
                Symbol("1", type: .int, meta: [.isLiteral]),
                Symbol("hello".quoted, type: .string, meta: [.isLiteral]),
            ]
        ))
    }

    func testPutLocal() throws {
        let symbol = try factory.init([
            .local("RFROB"),
            .decimal(1),
            .local("MSG")
        ]).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            "try rfrob.put(element: msg, at: 1)",
            type: .int
        ))
    }

    func testNonTableThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("TROLL"),
                .decimal(1),
                .decimal(123)
            ]).process()
        )
    }

    func testNonIndexThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .global("MYTABLE"),
                .string("1"),
                .decimal(123)
            ]).process()
        )
    }
}
