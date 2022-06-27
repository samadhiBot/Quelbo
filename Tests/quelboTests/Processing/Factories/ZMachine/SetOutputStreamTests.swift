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

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("DIROUT"))
    }

    func testSetOutputStreamScreenOff() throws {
        let symbol = try factory.init([
            .decimal(-1)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(code: "setOutputStream(.screenOff)", type: .void))
    }

    func testSetOutputStreamTranscriptFileOff() throws {
        let symbol = try factory.init([
            .decimal(-2)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(code: "setOutputStream(.transcriptFileOff)", type: .void))
    }

    func testSetOutputStreamTableOff() throws {
        let symbol = try factory.init([
            .decimal(-3)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(code: "setOutputStream(.tableOff)", type: .void))
    }

    func testSetOutputStreamCommandsFileOff() throws {
        let symbol = try factory.init([
            .decimal(-4)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(code: "setOutputStream(.commandsFileOff)", type: .void))
    }

    func testSetOutputStreamScreenOn() throws {
        let symbol = try factory.init([
            .decimal(1)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(code: "setOutputStream(.screenOn)", type: .void))
    }

    func testSetOutputStreamTranscriptFileOn() throws {
        let symbol = try factory.init([
            .decimal(2)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(code: "setOutputStream(.transcriptFileOn)", type: .void))
    }

    func testSetOutputStreamTableOn() throws {
        let symbol = try factory.init([
            .decimal(3)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(code: "setOutputStream(.tableOn)", type: .void))
    }

    func testSetOutputStreamCommandsFileOn() throws {
        let symbol = try factory.init([
            .decimal(4)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(code: "setOutputStream(.commandsFileOn)", type: .void))
    }
    func testNonIntegerThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("keyboard"),
            ]).process()
        )
    }

    func testInvalidIntegerThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(5),
            ]).process()
        )
    }
}
