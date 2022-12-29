//
//  NthElementTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class NthElementTests: QuelboTests {
    let factory = Factories.NthElement.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("NTH"))
    }

    func testNthElementInVector() throws {
        let symbol = process("""
            <NTH <VECTOR "AB" "CD" "EF"> 2>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: #"["AB", "CD", "EF"].nthElement(2)"#,
            type: .string.element,
            returnHandling: .forced
        ))
    }

    func testShortHandCall() throws {
        let symbol = process("""
            <SET A <2 <VECTOR "AB" "CD" "EF">>>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: #"a.set(to: ["AB", "CD", "EF"].nthElement(2))"#,
            type: .string.element
        ))
    }
}
