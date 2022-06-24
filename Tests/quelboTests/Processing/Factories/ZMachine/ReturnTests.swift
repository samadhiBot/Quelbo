//
//  ReturnTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/23/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ReturnTests: QuelboTests {
    let factory = Factories.Return.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol(id: "foo", type: .int),
            Symbol(id: "forest1", type: .object, category: .rooms),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("RETURN"))
    }

    func testReturnNoValueNoBlock() throws {
        let symbol = try factory.init([]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return true",
            type: .bool
        ))
    }

    func testReturnNoValueBlockWithDefaultActivationZ34() throws {
        Game.shared.zMachineVersion = .z3

        let symbol = try factory
            .init([], in: .blockWithDefaultActivation)
            .process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "break"
        ))
    }

    func testReturnNoValueBlockWithDefaultActivationZ5Plus() throws {
        Game.shared.zMachineVersion = .z5

        let symbol = try factory
            .init([], in: .blockWithDefaultActivation)
            .process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return true",
            type: .bool
        ))
    }

    func testReturnNoValueBlockWithoutDefaultActivation() throws {
        let symbol = try factory
            .init([], in: .blockWithoutDefaultActivation)
            .process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "break defaultAct"
        ))
    }

    func testReturnTrue() throws {
        let symbol = try factory.init([
            .bool(true)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return true",
            type: .bool
        ))
    }

    func testReturnAtomT() throws {
        let symbol = try factory.init([
            .atom("T")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return true",
            type: .bool
        ))
    }

    func testReturnFalse() throws {
        let symbol = try factory.init([
            .bool(false)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return false",
            type: .bool
        ))
    }

    func testReturnDecimal() throws {
        let symbol = try factory.init([
            .decimal(42)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return 42",
            type: .int
        ))
    }

    func testReturnString() throws {
        let symbol = try factory.init([
            .string("grue")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: #"return "grue""#,
            type: .string
        ))
    }

    func testReturnGlobal() throws {
        let symbol = try factory.init([
            .global("FOO")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return foo",
            type: .int
        ))
    }

    func testReturnRoom() throws {
        let symbol = try factory.init([
            .atom("FOREST-1")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return forest1",
            type: .object
        ))
    }
}
