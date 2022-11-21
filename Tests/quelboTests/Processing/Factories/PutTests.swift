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
            .variable(id: "mytable", type: .table, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("PUT"))
        AssertSameFactory(factory, Game.findFactory("PUTB"))
    }

    func testPutInteger() throws {
        let symbol = try factory.init([
            .global(.atom("MYTABLE")),
            .decimal(1),
            .decimal(123)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "try mytable.put(element: 123, at: 1)",
            type: .int.tableElement
        ))
    }

    func testPutString() throws {
        let symbol = try factory.init([
            .global(.atom("MYTABLE")),
            .decimal(1),
            .string("hello")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"try mytable.put(element: "hello", at: 1)"#,
            type: .string.tableElement
        ))
    }

    func testPutLocal() throws {
        localVariables.append(contentsOf: [
            Statement(id: "msg", type: .int),
            Statement(id: "rfrob", type: .unknown),
        ])

        let symbol = try factory.init([
            .local("RFROB"),
            .decimal(1),
            .local("MSG")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "try rfrob.put(element: msg, at: 1)",
            type: .int.tableElement
        ))
    }

    func testNonTableThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("TROLL"),
                .decimal(1),
                .decimal(123)
            ], with: &localVariables).process()
        )
    }

    func testNonIndexThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .global(.atom("MYTABLE")),
                .string("1"),
                .decimal(123)
            ], with: &localVariables).process()
        )
    }
}
