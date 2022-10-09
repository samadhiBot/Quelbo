//
//  SetOutputStreamTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SetOutputStreamTests: QuelboTests {
    let factory = Factories.SetOutputStream.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "outputTable", type: .table, category: .globals),
            .variable(id: "trapDoor", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("DIROUT"))
    }

    func testSetOutputStreamScreenOff() throws {
        let symbol = try factory.init([
            .decimal(-1)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "setOutputStream(.screenOff)",
            type: .void
        ))
    }

    func testSetOutputStreamTranscriptFileOff() throws {
        let symbol = try factory.init([
            .decimal(-2)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "setOutputStream(.transcriptFileOff)",
            type: .void
        ))
    }

    func testSetOutputStreamTableOff() throws {
        let symbol = try factory.init([
            .decimal(-3)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "setOutputStream(.tableOff)",
            type: .void
        ))
    }

    func testSetOutputStreamCommandsFileOff() throws {
        let symbol = try factory.init([
            .decimal(-4)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "setOutputStream(.commandsFileOff)",
            type: .void
        ))
    }

    func testSetOutputStreamScreenOn() throws {
        let symbol = try factory.init([
            .decimal(1)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "setOutputStream(.screenOn)",
            type: .void
        ))
    }

    func testSetOutputStreamTranscriptFileOn() throws {
        let symbol = try factory.init([
            .decimal(2)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "setOutputStream(.transcriptFileOn)",
            type: .void
        ))
    }

    func testSetOutputStreamTableOn() throws {
        let symbol = try factory.init([
            .decimal(3),
            .global(.atom("OUTPUT-TABLE"))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                setOutputStream(
                    .tableOn,
                    &outputTable
                )
                """,
            type: .void
        ))
    }

    func testSetOutputStreamTableOnNoTableFails() throws {
        XCTAssertThrowsError(
            _ = try factory.init([
                .decimal(3),
            ], with: &localVariables).process()
        )
    }

    func testSetOutputStreamTableOnNotTableFails() throws {
        XCTAssertThrowsError(
            _ = try factory.init([
                .decimal(3),
                .global(.atom("TRAP-DOOR"))
            ], with: &localVariables).process()
        )
    }

    func testSetOutputStreamCommandsFileOn() throws {
        let symbol = try factory.init([
            .decimal(4)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "setOutputStream(.commandsFileOn)",
            type: .void
        ))
    }
    func testNonIntegerThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("keyboard"),
            ], with: &localVariables).process()
        )
    }

    func testInvalidIntegerThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(5),
            ], with: &localVariables).process()
        )
    }
}
