//
//  ReadTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ReadTests: QuelboTests {
    let factory = Factories.Read.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "lexbuf", type: .table, category: .globals),
            .variable(id: "readbuf", type: .table, category: .globals),
            .variable(id: "notbuf", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("READ"))
    }

    func testReadDecimal() throws {
        let symbol = try factory.init([
            .global(.atom("READBUF")),
            .global(.atom("LEXBUF")),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "read(&readbuf, &lexbuf)",
            type: .void
        ))
    }

    func testReadNonTableThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .global(.atom("NOTBUF")),
                .global(.atom("LEXBUF")),
            ], with: &localVariables).process()
        )
    }
}
