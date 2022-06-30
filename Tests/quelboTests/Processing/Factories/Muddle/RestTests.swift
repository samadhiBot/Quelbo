//
//  RestTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/17/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class RestTests: QuelboTests {
    let factory = Factories.Rest.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("REST"))
    }

    func testRestOfIntegerList() throws {
        _ = try Factories.Global([
            .atom("STRUCT1"),
            .vector([
                .decimal(1),
                .decimal(2),
                .decimal(3),
                .decimal(4)
            ])
        ]).process()

        let symbol = try factory.init([
            .atom("STRUCT1"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "struct1.rest()",
            type: .variable(.array(.int))
        ))
    }

    func testRestOfMixedList() throws {
        _ = try Factories.Global([
            .atom("STRUCT2"),
            .vector([
                .decimal(1),
                .decimal(2),
                .string("AB"),
                .character("C"),
            ])
        ]).process()

        let symbol = try factory.init([
            .atom("STRUCT2"),
        ]).process()

        XCTAssertNoDifference(
            symbol,
            Symbol(
                code: "struct2.rest()",
                type: .variable(.array(.zilElement))
            )
        )
    }

    func testRestOfMixedListAfterFirstTwo() throws {
        _ = try Factories.Global([
            .atom("STRUCT3"),
            .vector([
                .decimal(1),
                .decimal(2),
                .string("AB"),
                .character("C"),
            ])
        ]).process()

        let symbol = try factory.init([
            .atom("STRUCT3"),
            .decimal(2)
        ]).process()

        XCTAssertNoDifference(
            symbol,
            Symbol(
                code: "struct3.rest(2)",
                type: .variable(.array(.zilElement)) 
            )
        )
    }
}
