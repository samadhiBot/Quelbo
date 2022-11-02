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
            .variable(id: "foo", type: .int),
            .variable(id: "forest1", type: .object, category: .rooms),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("RETURN"))
    }

    func testReturnNoValueNoBlock() throws {
        localVariables.append(.init(id: "n", type: .int))

        let symbol = try Factories.Condition([
            .list([
                .form([
                    .atom("0?"),
                    .local("N")
                ]),
                .form([
                    .atom("RETURN")
                ])
            ]),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                if n.isZero {
                    break
                }
                """,
            type: .void,
            returnHandling: .suppress
        ))
    }

    func testReturnNoValueBlockWithDefaultActivationZ34() throws {
        Game.reset(zMachineVersion: .z3)

        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "break",
            type: .void
        ))
    }

    func testReturnNoValueBlockWithDefaultActivationZ5Plus() throws {
        Game.reset(zMachineVersion: .z5)

        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "return true",
            type: .bool,
            isReturnStatement: true
        ))
    }

    func testReturnNoValueBlockWithoutDefaultActivation() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "break",
            type: .void
        ))
    }

    func testReturnTrue() throws {
        let symbol = try factory.init([
            .bool(true)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "return true",
            type: .booleanTrue,
            isReturnStatement: true
        ))
    }

    func testReturnAtomT() throws {
        let symbol = try factory.init([
            .atom("T")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "return true",
            type: .booleanTrue,
            isReturnStatement: true
        ))
    }

    func testReturnFalse() throws {
        let symbol = try factory.init([
            .bool(false)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "return false",
            type: .booleanFalse,
            isReturnStatement: true
        ))
    }

    func testReturnDecimal() throws {
        let symbol = try factory.init([
            .decimal(42)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "return 42",
            type: .int,
            isReturnStatement: true
        ))
    }

    func testReturnString() throws {
        let symbol = try factory.init([
            .string("grue")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"return "grue""#,
            type: .string,
            isReturnStatement: true
        ))
    }

    func testReturnGlobal() throws {
        let symbol = try factory.init([
            .global(.atom("FOO"))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "return foo",
            type: .int,
            isReturnStatement: true
        ))
    }

    func testReturnRoom() throws {
        let symbol = try factory.init([
            .atom("FOREST-1")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "return forest1",
            type: .object,
            isReturnStatement: true
        ))
    }
}
