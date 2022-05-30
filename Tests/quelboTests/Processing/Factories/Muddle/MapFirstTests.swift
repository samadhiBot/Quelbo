//
//  MapFirst.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/8/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class MapFirstTests: QuelboTests {
    let factory = Factories.MapFirst.self

    override func setUp() {
        super.setUp()

        try! Game.commit(
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("MAPF"))
    }

    func testMapFirstVectorAdd() throws {
        let symbol = try factory.init([
            .global("VECTOR"),
            .global("+"),
            .list([
                .decimal(1),
                .decimal(2),
                .decimal(3)
            ]),
            .vector([
                .decimal(10),
                .decimal(11),
                .decimal(12)
            ])
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
            [
                .add(1, 10),
                .add(2, 11),
                .add(3, 12),
            ]
            """,
            type: .array(.int),
            children: [
                Symbol(
                    ".add(1, 10)",
                    type: .int,
                    children: [
                        Symbol("1", type: .int, meta: [.isLiteral]),
                        Symbol("10", type: .int, meta: [.isLiteral]),
                    ]
                ),
                Symbol(
                    ".add(2, 11)",
                    type: .int,
                    children: [
                        Symbol("2", type: .int, meta: [.isLiteral]),
                        Symbol("11", type: .int, meta: [.isLiteral]),
                    ]
                ),
                Symbol(
                    ".add(3, 12)",
                    type: .int,
                    children: [
                        Symbol("3", type: .int, meta: [.isLiteral]),
                        Symbol("12", type: .int, meta: [.isLiteral]),
                    ]
                )
            ]
        ))
    }

    func testMapFirstStringFirst() throws {
        let symbol = try factory.init([
            .global("STRING"),
            .decimal(1),
            .vector([
                .string("Zil"),
                .string("is"),
                .string("lots of"),
                .string("fun")
            ])
        ], with: types).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            """
            [
                "Zil".nthElement(1),
                "is".nthElement(1),
                "lots of".nthElement(1),
                "fun".nthElement(1),
            ].joined()
            """,
            type: .string
        ))
    }

    func testMapFirstVectorAnonymousFunction() throws {
        let symbol = try factory.init([
            .global("VECTOR"),
            .form([
                .atom("FUNCTION"),
                .list([
                    .atom("N")
                ]),
                .form([
                    .atom("*"),
                    .local("N"),
                    .local("N")
                ])
            ]),
            .list([
                .decimal(1),
                .decimal(2),
                .decimal(3)
            ])
        ], with: types).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            """
            [
                { (n: Int) -> Int in
                    var n = n
                    return n.multiply(n)
                }(1),
                { (n: Int) -> Int in
                    var n = n
                    return n.multiply(n)
                }(2),
                { (n: Int) -> Int in
                    var n = n
                    return n.multiply(n)
                }(3),
            ]
            """,
            type: .array(.int)
        ))
    }
}
