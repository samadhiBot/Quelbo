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

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("ITABLE"))
    }

    func testInitTableFourZeros() throws {
        let symbol = try factory.init([
            .decimal(4),
            .decimal(0),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                Table(
                    .int(0),
                    .int(0),
                    .int(0),
                    .int(0)
                )
                """,
            type: .table,
            children: [
                zeroZilElementSymbol,
                zeroZilElementSymbol,
                zeroZilElementSymbol,
                zeroZilElementSymbol,
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
                    .int(0),
                    .int(0),
                    .int(0),
                    .int(0),
                    hasLengthFlag: true
                )
                """,
            type: .table,
            children: [
                zeroZilElementSymbol,
                zeroZilElementSymbol,
                zeroZilElementSymbol,
                zeroZilElementSymbol,
                Symbol("hasLengthFlag: true"),
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
                    .int(0),
                    .int(0),
                    .int(0),
                    .int(0),
                    hasLengthFlag: true
                )
                """,
            type: .table,
            children: [
                zeroZilElementSymbol,
                zeroZilElementSymbol,
                zeroZilElementSymbol,
                zeroZilElementSymbol,
                Symbol("hasLengthFlag: true"),
            ]
        ))
    }

    func testInitTableNoneFourZeros() throws {
        let symbol = try factory.init([
            .atom("NONE"),
            .decimal(4),
            .decimal(0),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                Table(
                    .int(0),
                    .int(0),
                    .int(0),
                    .int(0)
                )
                """,
            type: .table,
            children: [
                zeroZilElementSymbol,
                zeroZilElementSymbol,
                zeroZilElementSymbol,
                zeroZilElementSymbol,
            ]
        ))
    }

}
