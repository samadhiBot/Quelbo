//
//  IsParsedDirectObjectTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsParsedDirectObjectTests: QuelboTests {
    let factory = Factories.IsParsedDirectObject.self

    override func setUp() {
        super.setUp()

        process("""
            <OBJECT LITTLE-BIRD>
            <OBJECT OIL-IN-BOTTLE>
            <OBJECT WATER-IN-BOTTLE>
        """)
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("PRSO?"))
    }

    func testIsParsedDirectObjectSingle() throws {
        let symbol = process("<PRSO? ,LITTLE-BIRD>")

        XCTAssertNoDifference(symbol, .statement(
            code: """
                isParsedDirectObject(Objects.littleBird)
                """,
            type: .bool
        ))
    }

    func testIsParsedDirectObjectMultiple() throws {
        let symbol = process("<PRSO? ,WATER-IN-BOTTLE ,OIL-IN-BOTTLE>")

        XCTAssertNoDifference(symbol, .statement(
            code: """
                isParsedDirectObject(
                    Objects.waterInBottle,
                    Objects.oilInBottle
                )
                """,
            type: .bool
        ))
    }
}
