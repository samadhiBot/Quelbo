//
//  ListTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/4/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ListTests: QuelboTests {
    let factory = Factories.List.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("LIST"))
    }

    func testIntegerList() throws {
        let symbol = try factory.init([
            .decimal(1),
            .decimal(2),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "[1, 2, 3]",
            type: .array(.int)
        ))
    }

    func testStringList() throws {
        let symbol = try factory.init([
            .string("AB"),
            .string("CD"),
            .string("EF"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            #"["AB", "CD", "EF"]"#,
            type: .array(.string)
        ))
    }

    func testMixedList() throws {
        let symbol = try factory.init([
            .decimal(1),
            .decimal(2),
            .string("AB"),
            .character("C"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "[1, 2, \"AB\", \"C\"]",
            type: .array(.zilElement)
        ))
    }
}
