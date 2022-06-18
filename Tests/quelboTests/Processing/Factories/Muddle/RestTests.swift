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

    override func setUp() {
        super.setUp()

        try! Game.commit(
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("REST"))
    }

    func testRestOfIntegerList() throws {
        let types = SymbolFactory.TypeRegistry()

        _ = try Factories.Global([
            .atom("STRUCT1"),
            .vector([
                .decimal(1),
                .decimal(2),
                .decimal(3),
                .decimal(4)
            ])
        ], with: types).process()

        let symbol = try factory.init([
            .atom("STRUCT1"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "struct1.rest()",
            type: .array(.int),
            children: [
                Symbol(
                    "struct1",
                    type: .array(.int),
                    category: .globals,
                    children: [
                        Symbol(
                            "[1, 2, 3, 4]",
                            type: .array(.int),
                            children: [
                                Symbol("1", type: .int, meta: [.isLiteral]),
                                Symbol("2", type: .int, meta: [.isLiteral]),
                                Symbol("3", type: .int, meta: [.isLiteral]),
                                Symbol("4", type: .int, meta: [.isLiteral]),
                            ]
                        )
                    ]
                )

            ]
        ))
    }

    func testRestOfMixedList() throws {
        let types = SymbolFactory.TypeRegistry()

        _ = try Factories.Global([
            .atom("STRUCT2"),
            .vector([
                .decimal(1),
                .decimal(2),
                .string("AB"),
                .character("C"),
            ])
        ], with: types).process()

        let symbol = try factory.init([
            .atom("STRUCT2"),
        ]).process()

        XCTAssertNoDifference(
            symbol.ignoringChildren,
            Symbol("struct2.rest()", type: .array(.zilElement))
        )
    }

    func testRestOfMixedListAfterFirstTwo() throws {
        let types = SymbolFactory.TypeRegistry()

        _ = try Factories.Global([
            .atom("STRUCT3"),
            .vector([
                .decimal(1),
                .decimal(2),
                .string("AB"),
                .character("C"),
            ])
        ], with: types).process()

        let symbol = try factory.init([
            .atom("STRUCT3"),
            .decimal(2)
        ]).process()

        XCTAssertNoDifference(
            symbol.ignoringChildren,
            Symbol("struct3.rest(2)", type: .array(.zilElement))
        )
    }
}
