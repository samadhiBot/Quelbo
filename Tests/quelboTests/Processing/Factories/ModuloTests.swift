//
//  ModuloTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/18/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class ModuloTests: QuelboTests {
    let factory = Factories.Modulo.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("MOD"))
    }

    func testModuloTwoDecimals() throws {
        let symbol = process("<MOD 9 3>")

        XCTAssertNoDifference(symbol, .statement(
            code: ".modulo(9, 3)",
            type: .int,
            returnHandling: .implicit
        ))
    }

    func testModuloThreeDecimalsThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .decimal(3),
                .decimal(3),
            ], with: &localVariables).process()
        )
    }

    func testModuloTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                .modulo(
                    bigNumber,
                    biggerNumber
                )
                """,
            type: .int,
            returnHandling: .implicit
        ))
    }

    func testModuloOneDecimalThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
            ], with: &localVariables)
        )
    }

    func testEvaluate() throws {
        XCTAssertNoDifference(
            evaluate("<MOD 15 4>"),
            .literal(3)
        )

        XCTAssertNoDifference(
            process("<PRINTN %<MOD 17 3>>"),
            .statement(
                code: "output(2)",
                type: .void
            )
        )
    }
}
