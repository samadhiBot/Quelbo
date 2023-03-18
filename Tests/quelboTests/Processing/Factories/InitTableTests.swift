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

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("ITABLE"))
    }

    func testInitTableFourImpliedZeros() throws {
        let symbol = try factory.init([
            .decimal(4),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Table(count: 4)",
            type: .table,
            isMutable: true,
            returnHandling: .implicit
        ))
    }

    func testInitTableFourZeros() throws {
        let symbol = try factory.init([
            .decimal(4),
            .decimal(0),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Table(count: 4, defaults: 0)",
            type: .table,
            isMutable: true,
            returnHandling: .implicit
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    count: 4,
                    defaults: 0,
                    flags: .byte, .length
                )
                """,
            type: .table,
            isMutable: true,
            returnHandling: .implicit
        ))
    }

    func testInitTableByteFourZeros() throws {
        let symbol = try factory.init([
            .atom("BYTE"),
            .decimal(4),
            .decimal(0)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    count: 4,
                    defaults: 0,
                    flags: .byte, .length
                )
                """,
            type: .table,
            isMutable: true,
            returnHandling: .implicit
        ))
    }

    func testInitTableNoneOneHundredZeros() throws {
        let symbol = try factory.init([
            .atom("NONE"),
            .decimal(100)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Table(count: 100, flags: .none)",
            type: .table,
            isMutable: true,
            returnHandling: .implicit
        ))
    }

    func testInitTableNoneGlobalBytes() throws {
        let symbol = try factory.init([
            .atom("NONE"),
            .global(.atom("READBUF-SIZE")),
            .list([
                .atom("BYTE")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Table(count: readbufSize, flags: .byte, .none)",
            type: .table,
            isMutable: true,
            returnHandling: .implicit
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    count: 59,
                    defaults: .int(0), .int8(0), .int8(0),
                    flags: .lexv
                )
                """,
            type: .table,
            isMutable: true,
            returnHandling: .implicit
        ))
    }
}
