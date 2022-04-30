//
//  InsertFileTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/20/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class InsertFileTests: QuelboTests {
    let factory = Factories.InsertFile.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("INSERT-FILE"))
    }

    func testString() throws {
        let symbol = try factory.init([
            .string("parser")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "// Insert file \'\"parser\"\'",
            type: .comment
        ))
    }
}
