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
        AssertSameFactory(factory, Game.findFactory("VERSION"))
    }

    func testAtom() throws {
        let symbol = try factory.init([
            .atom("ZIP")
        ], with: &localVariables).process()

        let expected = Statement(
            id: "zMachineVersion",
            code: #"let zMachineVersion: String = "z3""#,
            type: .string,
            confidence: .certain,
            category: .constants
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.shared.symbols.find("zMachineVersion"), expected)
    }

    func testZ3WithTime() throws {
        let symbol = try factory.init([
            .atom("ZIP"),
            .atom("TIME")
        ], with: &localVariables).process()

        let expected = Statement(
            id: "zMachineVersion",
            code: #"let zMachineVersion: String = "z3Time""#,
            type: .string,
            confidence: .certain,
            category: .constants
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.shared.symbols.find("zMachineVersion"), expected)
    }

    func testDecimal() throws {
        let symbol = try factory.init([
            .decimal(3)
        ], with: &localVariables).process()

        let expected = Statement(
            id: "zMachineVersion",
            code: #"let zMachineVersion: String = "z3""#,
            type: .string,
            confidence: .certain,
            category: .constants
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.shared.symbols.find("zMachineVersion"), expected)
    }

    func testUnknownVersionDecimalThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
            ], with: &localVariables)
        )
    }

    func testUnknownVersionAtomThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("ZAP"),
            ], with: &localVariables)
        )
    }
}
