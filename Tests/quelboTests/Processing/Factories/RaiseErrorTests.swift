//
//  RaiseErrorTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/8/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class RaiseErrorTests: QuelboTests {
    let factory = Factories.RaiseError.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("ERROR"))
    }

    func testRaiseError() throws {
        localVariables.append(
            Variable(id: "atms", type: .array(.zilElement))
        )

        let symbol = try factory.init([
            .local("ATMS"),
            .decimal(5),
            .string("Warning")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "throw FizmoError.mdlError(atms, 5, \"Warning\")",
            type: .void,
            confidence: .void
        ))
    }
}
