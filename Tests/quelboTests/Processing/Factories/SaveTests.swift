//
//  SaveTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SaveTests: QuelboTests {
    let factory = Factories.Save.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("SAVE"))
    }

    func testSave() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "save()",
            type: .void,
            confidence: .certain
        ))
    }

    func testSaveWithParameterThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42),
            ], with: &localVariables).process()
        )
    }
}
