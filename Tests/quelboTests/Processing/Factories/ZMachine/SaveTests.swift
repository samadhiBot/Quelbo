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
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("SAVE"))
    }

    func testSave() throws {
        let symbol = try factory.init([]).process()

        XCTAssertNoDifference(symbol, Symbol("save()", type: .void))
    }

    func testSaveWithParameterThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42),
            ]).process()
        )
    }
}
