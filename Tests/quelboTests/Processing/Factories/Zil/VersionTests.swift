//
//  VersionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/20/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class VersionTests: QuelboTests {
    let factory = Factories.Version.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("VERSION"))
    }

    func testAtom() throws {
        let symbol = try factory.init([
            .atom("ZIP")
        ], with: types).process()

        let expected = Symbol(
            id: "zMachineVersion",
            code: #"let zMachineVersion: String = "z3""#,
            type: .string,
            category: .constants
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("zMachineVersion", category: .constants), expected)
    }

    func testZ3WithTime() throws {
        let symbol = try factory.init([
            .atom("ZIP"),
            .atom("TIME")
        ], with: types).process()

        let expected = Symbol(
            id: "zMachineVersion",
            code: #"let zMachineVersion: String = "z3Time""#,
            type: .string,
            category: .constants
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("zMachineVersion", category: .constants), expected)
    }

    func testDecimal() throws {
        let symbol = try factory.init([
            .decimal(3)
        ], with: types).process()

        let expected = Symbol(
            id: "zMachineVersion",
            code: #"let zMachineVersion: String = "z3""#,
            type: .string,
            category: .constants
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("zMachineVersion", category: .constants), expected)
    }

    func testUnknownVersionDecimalThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
            ], with: types)
        )
    }

    func testUnknownVersionAtomThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("ZAP"),
            ], with: types)
        )
    }
}
