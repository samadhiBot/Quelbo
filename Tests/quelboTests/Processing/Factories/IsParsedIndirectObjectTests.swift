//
//  IsParsedIndirectObjectTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsParsedIndirectObjectTests: QuelboTests {
    let factory = Factories.IsParsedIndirectObject.self

    override func setUp() {
        super.setUp()

        process("""
            <OBJECT WICKER-CAGE>
            <OBJECT BOTTLE>
        """)
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("PRSI?"))
    }

    func testIsParsedIndirectObjectSingle() throws {
        let symbol = process("<PRSI? ,WICKER-CAGE>")

        XCTAssertNoDifference(symbol, .statement(
            code: """
                isParsedIndirectObject(Objects.wickerCage)
                """,
            type: .bool
        ))
    }

    func testIsParsedIndirectObjectMultiple() throws {
        let symbol = process("<PRSI? ,WICKER-CAGE ,BOTTLE>")

        XCTAssertNoDifference(symbol, .statement(
            code: """
                isParsedIndirectObject(Objects.wickerCage, Objects.bottle)
                """,
            type: .bool
        ))
    }
}
