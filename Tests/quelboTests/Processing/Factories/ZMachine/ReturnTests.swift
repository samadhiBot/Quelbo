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
            Symbol("foo", type: .int),
            Symbol("forest1", type: .object, category: .rooms),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("RETURN"))
    }

    func testReturnNoValueNoBlock() throws {
        let symbol = try factory.init([], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return true",
            type: .bool,
            children: [.trueSymbol]
        ))
    }

    func testReturnNoValueBlockWithDefaultActivationZ34() throws {
        Game.shared.zMachineVersion = .z3

        let symbol = try factory
            .init([], in: .blockWithDefaultActivation, with: types)
            .process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "break"
        ))
    }

    func testReturnNoValueBlockWithDefaultActivationZ5Plus() throws {
        Game.shared.zMachineVersion = .z5

        let symbol = try factory
            .init([], in: .blockWithDefaultActivation, with: types)
            .process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return true",
            type: .bool,
            children: [.trueSymbol]
        ))
    }

    func testReturnNoValueBlockWithoutDefaultActivation() throws {
        let symbol = try factory
            .init([], in: .blockWithoutDefaultActivation, with: types)
            .process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "break defaultAct"
        ))
    }

    func testReturnTrue() throws {
        let symbol = try factory.init([
            .bool(true)
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return true",
            type: .bool,
            children: [.trueSymbol]
        ))
    }

    func testReturnAtomT() throws {
        let symbol = try factory.init([
            .atom("T")
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return true",
            type: .bool,
            children: [.trueSymbol]
        ))
    }

    func testReturnFalse() throws {
        let symbol = try factory.init([
            .bool(false)
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return false",
            type: .bool,
            children: [.falseSymbol]
        ))
    }

    func testReturnDecimal() throws {
        let symbol = try factory.init([
            .decimal(42)
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return 42",
            type: .int,
            children: [
                Symbol("42", type: .int, meta: [.isLiteral])
            ]
        ))
    }

    func testReturnString() throws {
        let symbol = try factory.init([
            .string("grue")
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: #"return "grue""#,
            type: .string,
            children: [
                Symbol(#""grue""#, type: .string, meta: [.isLiteral])
            ]
        ))
    }

    func testReturnGlobal() throws {
        let symbol = try factory.init([
            .global("FOO")
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return foo",
            type: .int,
            children: [
                Symbol("foo", type: .int)
            ]
        ))
    }

    func testReturnRoom() throws {
        let symbol = try factory.init([
            .atom("FOREST-1")
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Return>",
            code: "return forest1",
            type: .object,
            children: [
                Symbol("forest1", type: .object, category: .rooms)
            ]
        ))
    }
}
