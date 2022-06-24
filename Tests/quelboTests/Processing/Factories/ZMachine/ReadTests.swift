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
            Symbol(id: "lexbuf", type: .table, category: .globals),
            Symbol(id: "readbuf", type: .table, category: .globals),
            Symbol(id: "notbuf", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("READ"))
    }

    func testReadDecimal() throws {
        let symbol = try factory.init([
            .global("READBUF"),
            .global("LEXBUF"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "read(readbuf lexbuf)",
            type: .void
        ))
    }

    func testReadNonTableThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .global("NOTBUF"),
                .global("LEXBUF"),
            ]).process()
        )
    }
}
