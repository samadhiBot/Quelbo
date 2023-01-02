//
//  BackTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 12/30/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class BackTests: QuelboTests {
    let factory = Factories.Back.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("BACK"))
    }

    func testBack() throws {
        let symbol = process("""
            <BACK .BEG 4>
        """, with: [
            Statement(id: "beg", type: .table),
        ])

        XCTAssertNoDifference(symbol, .statement(
            code: "beg.back(bytes: 4)",
            type: .table
        ))
    }

    func testBackWithParameter() throws {
        let symbol = process("""
            <BACK .BEG>
        """, with: [
            Statement(id: "beg", type: .table),
        ])

        XCTAssertNoDifference(symbol, .statement(
            code: "beg.back(bytes: 1)",
            type: .table
        ))
    }
}
