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
        let symbol = process("<VERSION ZIP>")

        let expected = Statement(
            id: "zMachineVersion",
            code: #"let zMachineVersion: String = "z3""#,
            type: .string,
            category: .constants,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.findInstance("zMachineVersion"), Instance(expected))
    }

    func testZ3WithTime() throws {
        let symbol = process("<VERSION ZIP TIME>")

        let expected = Statement(
            id: "zMachineVersion",
            code: #"let zMachineVersion: String = "z3Time""#,
            type: .string,
            category: .constants,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.findInstance("zMachineVersion"), Instance(expected))
    }

    func testDecimal() throws {
        let symbol = process("<VERSION 3>")

        let expected = Statement(
            id: "zMachineVersion",
            code: #"let zMachineVersion: String = "z3""#,
            type: .string,
            category: .constants,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.findInstance("zMachineVersion"), Instance(expected))
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
