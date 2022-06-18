//
//  InitTableTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/7/22.
//

import Foundation

import CustomDump
import XCTest
@testable import quelbo

final class InitTableTests: QuelboTests {
    let factory = Factories.InitTable.self
    let zeroZilElementSymbol = Symbol.zeroSymbol.with(code: ".int(0)", type: .zilElement)

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol(id: "readbufSize", type: .int, category: .constants)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("ITABLE"))
    }

    func testInitTableFourImpliedZeros() throws {
        let symbol = try factory.init([
            .decimal(4),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "Table(count: 4)",
            type: .table,
            children: [
                Symbol("count: 4"),
            ]
        ))
    }

    func testInitTableFourZeros() throws {
        let symbol = try factory.init([
            .decimal(4),
            .decimal(0),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                Table(
                    count: 4,
                    defaults: [.int(0)]
                )
                """,
            type: .table,
            children: [
                Symbol("count: 4"),
                Symbol("defaults: [.int(0)]"),
            ]
        ))
    }

    func testInitTableByteLengthFourZeros() throws {
        let symbol = try factory.init([
            .list([
                .atom("BYTE"),
                .atom("LENGTH")
            ]),
            .decimal(4),
            .decimal(0)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                Table(
                    count: 4,
                    defaults: [.int(0)],
                    flags: [.byte, .length]
                )
                """,
            type: .table,
            children: [
                Symbol("count: 4"),
                Symbol("defaults: [.int(0)]"),
                Symbol("flags: [.byte, .length]")
            ]
        ))
    }

    func testInitTableByteFourZeros() throws {
        let symbol = try factory.init([
            .atom("BYTE"),
            .decimal(4),
            .decimal(0)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                Table(
                    count: 4,
                    defaults: [.int(0)],
                    flags: [.byte, .length]
                )
                """,
            type: .table,
            children: [
                Symbol("count: 4"),
                Symbol("defaults: [.int(0)]"),
                Symbol("flags: [.byte, .length]")
            ]
        ))
    }

    func testInitTableNoneOneHundredZeros() throws {
        let symbol = try factory.init([
            .atom("NONE"),
            .decimal(100)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                Table(
                    count: 100,
                    flags: [.none]
                )
                """,
            type: .table,
            children: [
                Symbol("count: 100"),
                Symbol("flags: [.none]")
            ]
        ))
    }

    func testInitTableNoneGlobalBytes() throws {
        let symbol = try factory.init([
            .atom("NONE"),
            .global("READBUF-SIZE"),
            .list([
                .atom("BYTE")
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                Table(
                    count: readbufSize,
                    flags: [.byte, .none]
                )
                """,
            type: .table,
            children: [
                Symbol("count: readbufSize"),
                Symbol("flags: [.byte, .none]")
            ]
        ))
    }

    func testInitTableRepeatingDefaults() throws {
        let symbol = try factory.init([
            .decimal(59),
            .list([
                .atom("LEXV")
            ]),
            .decimal(0),
            .type("BYTE"),
            .decimal(0),
            .type("BYTE"),
            .decimal(0)
        ]).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            """
                Table(
                    count: 59,
                    defaults: [
                        .int(0),
                        .int8(0),
                        .int8(0),
                    ],
                    flags: [.lexv]
                )
                """,
            type: .table
        ))
    }
}
