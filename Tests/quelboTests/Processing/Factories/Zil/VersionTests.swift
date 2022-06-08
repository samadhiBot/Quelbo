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
        ]).process()

        let expected = Symbol(
            id: "zMachineVersion",
            code: #"let zMachineVersion: String = "z3""#,
            type: .string,
            category: .constants,
            children: [
                Symbol("z3".quoted, type: .string, meta: [.isLiteral])
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("zMachineVersion", category: .constants), expected)
    }

    func testZ3WithTime() throws {
        let symbol = try factory.init([
            .atom("ZIP"),
            .atom("TIME")
        ]).process()

        let expected = Symbol(
            id: "zMachineVersion",
            code: #"let zMachineVersion: String = "z3Time""#,
            type: .string,
            category: .constants,
            children: [
                Symbol("z3Time".quoted, type: .string, meta: [.isLiteral])
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("zMachineVersion", category: .constants), expected)
    }

    func testDecimal() throws {
        let symbol = try factory.init([
            .decimal(3)
        ]).process()

        let expected = Symbol(
            id: "zMachineVersion",
            code: #"let zMachineVersion: String = "z3""#,
            type: .string,
            category: .constants,
            children: [
                Symbol("z3".quoted, type: .string, meta: [.isLiteral])
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("zMachineVersion", category: .constants), expected)
    }

    func testUnknownVersionDecimalThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
            ])
        )
    }

    func testUnknownVersionAtomThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("ZAP"),
            ])
        )
    }
}
