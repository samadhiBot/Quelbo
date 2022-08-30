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
            confidence: .certain,
            isMutable: true
        ))
    }

    func testInitTableFourZeros() throws {
        let symbol = try factory.init([
            .decimal(4),
            .decimal(0),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    count: 4,
                    defaults: [.int(0)]
                )
                """,
            type: .table,
            confidence: .certain,
            isMutable: true
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
                    defaults: [.int(0)],
                    flags: [.byte, .length]
                )
                """,
            type: .table,
            confidence: .certain,
            isMutable: true
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
                    defaults: [.int(0)],
                    flags: [.byte, .length]
                )
                """,
            type: .table,
            confidence: .certain,
            isMutable: true
        ))
    }

    func testInitTableNoneOneHundredZeros() throws {
        let symbol = try factory.init([
            .atom("NONE"),
            .decimal(100)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    count: 100,
                    flags: [.none]
                )
                """,
            type: .table,
            confidence: .certain,
            isMutable: true
        ))
    }

    func testInitTableNoneGlobalBytes() throws {
        let symbol = try factory.init([
            .atom("NONE"),
            .global("READBUF-SIZE"),
            .list([
                .atom("BYTE")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    count: readbufSize,
                    flags: [.byte, .none]
                )
                """,
            type: .table,
            confidence: .certain,
            isMutable: true
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
                    defaults: [
                        .int(0),
                        .int8(0),
                        .int8(0),
                    ],
                    flags: [.lexv]
                )
                """,
            type: .table,
            confidence: .certain,
            isMutable: true
        ))
    }
}
