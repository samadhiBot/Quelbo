//
//  DivideTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DivideTests: QuelboTests {
    let factory = Factories.Divide.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("/"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("DIV"))
    }

    func testDivideTwoDecimals() throws {
        let symbol = try factory.init([
            .decimal(9),
            .decimal(3),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "9.divide(3)",
            type: .int,
            children: [
                Symbol(id: "9", type: .int),
                Symbol(id: "3", type: .int),
            ]
        ))
    }

    func testDivideThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(20),
            .decimal(5),
            .decimal(2),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "20.divide(5, 2)",
            type: .int,
            children: [
                Symbol(id: "20", type: .int),
                Symbol(id: "5", type: .int),
                Symbol(id: "2", type: .int),
            ]
        ))
    }

    func testDivideOneDecimalThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
            ])
        )
    }
}
