//
//  ContainerFunctionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 2/13/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class ContainerFunctionTests: QuelboTests {
    let factory = Factories.ContainerFunction.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("CONTFCN", type: .property))
    }

    func testContainerFunction() throws {
        let symbol = try factory.init([
            .atom("BAT-D")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "containerFunction",
            code: "containerFunction: batD",
            type: .routine
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "containerFunction",
            type: .routine
        ))
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("WHITE-HOUSE"),
                .atom("RED-HOUSE"),
            ], with: &localVariables).process()
        )
    }
}
