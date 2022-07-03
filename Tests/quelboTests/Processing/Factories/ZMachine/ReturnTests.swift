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

        Game.commit([
            Symbol(id: "foo", type: .int),
            Symbol(id: "forest1", type: .object, category: .rooms),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("RETURN"))
    }

    func testReturnNoValueNoBlock() throws {
        let symbol = try factory.init([], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "return true",
            meta: []
        ))
    }

    func testReturnNoValueBlockWithDefaultActivationZ34() throws {
        Game.shared.zMachineVersion = .z3

        let symbol = try factory.init([], with: &registry).process()
        symbol.meta = []

        XCTAssertNoDifference(symbol, Symbol(
            code: "break",
            meta: []
        ))
    }

    func testReturnNoValueBlockWithDefaultActivationZ5Plus() throws {
        Game.shared.zMachineVersion = .z5

        let symbol = try factory.init([], with: &registry).process()
        symbol.meta = []

        XCTAssertNoDifference(symbol, Symbol(
            code: "return true",
            meta: []
        ))
    }

    func testReturnNoValueBlockWithoutDefaultActivation() throws {
        let symbol = try factory.init([], with: &registry).process()
        symbol.meta = []

        XCTAssertNoDifference(symbol, Symbol(
            code: "break defaultAct",
            meta: []
        ))
    }

    func testReturnTrue() throws {
        let symbol = try factory.init([
            .bool(true)
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "return true",
            type: .bool,
            meta: []
        ))
    }

    func testReturnAtomT() throws {
        let symbol = try factory.init([
            .atom("T")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "return true",
            type: .bool,
            meta: []
        ))
    }

    func testReturnFalse() throws {
        let symbol = try factory.init([
            .bool(false)
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "return false",
            type: .bool,
            meta: []
        ))
    }

    func testReturnDecimal() throws {
        let symbol = try factory.init([
            .decimal(42)
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "return 42",
            type: .int,
            meta: []
        ))
    }

    func testReturnString() throws {
        let symbol = try factory.init([
            .string("grue")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: #"return "grue""#,
            type: .string,
            meta: []
        ))
    }

    func testReturnGlobal() throws {
        let symbol = try factory.init([
            .global("FOO")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "return foo",
            type: .int,
            meta: []
        ))
    }

    func testReturnRoom() throws {
        let symbol = try factory.init([
            .atom("FOREST-1")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "return forest1",
            type: .object,
            meta: []
        ))
    }
}
