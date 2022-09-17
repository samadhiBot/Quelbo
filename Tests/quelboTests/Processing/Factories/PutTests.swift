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
            .global("MYTABLE"),
            .decimal(1),
            .decimal(123)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "try mytable.put(element: .int(123), at: 1)",
            type: .init(
                dataType: .int,
                confidence: .certain,
                isZilElement: true
            )
        ))
    }

    func testPutString() throws {
        let symbol = try factory.init([
            .global("MYTABLE"),
            .decimal(1),
            .string("hello")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"try mytable.put(element: .string("hello"), at: 1)"#,
            type: .init(
                dataType: .string,
                confidence: .certain,
                isZilElement: true
            )
        ))
    }

    func testPutLocal() throws {
        localVariables.append(contentsOf: [
            Variable(id: "msg", type: .int),
            Variable(id: "rfrob", type: .unknown),
        ])

        let symbol = try factory.init([
            .local("RFROB"),
            .decimal(1),
            .local("MSG")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "try rfrob.put(element: msg, at: 1)",
            type: .init(
                dataType: .int,
                confidence: .certain,
                isZilElement: true
            )
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
                .global("MYTABLE"),
                .string("1"),
                .decimal(123)
            ], with: &localVariables).process()
        )
    }
}
