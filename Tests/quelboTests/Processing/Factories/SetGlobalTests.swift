//
//  SetGlobalTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/12/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class SetGlobalTests: QuelboTests {
    let factory = Factories.SetGlobal.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("SETG", type: .zCode))
    }

    func testSetGlobal() throws {
        process("<GLOBAL FOO <>>")

        let symbol = process("<SETG FOO 42>", type: .zCode)

        XCTAssertNoDifference(symbol, .statement(
            code: "Globals.foo.set(to: 42)",
            type: .int.optional
        ))

        XCTAssertNoDifference(
            Game.globals.find("foo"),
            Statement(
                id: "foo",
                code: "var foo: Int?",
                type: .int.optional,
                category: .globals,
                isCommittable: true,
                isMutable: true
            )
        )
    }

    func testSetGlobalToLocalVariable() throws {
        process("<GLOBAL FOO <>>")

        let symbol = process(
            "<SETG FOO N>",
            type: .zCode,
            with: [
                Statement(id: "n", type: .string)
            ]
        )

        XCTAssertNoDifference(symbol, .statement(
            code: "Globals.foo.set(to: n)",
            type: .string.optional
        ))
    }

    func testSetGlobalToModifiedSelf() throws {
        process("<GLOBAL N 0>")

        let symbol = process(
            "<SETG N <- N 1>>",
            type: .zCode,
            with: [
                Statement(id: "n", type: .int)
            ]
        )

        XCTAssertNoDifference(symbol, .statement(
            code: "Globals.n.set(to: .subtract(Globals.n, 1))",
            type: .int
        ))
    }

    func testReassignConstantToGlobal() throws {
        process("<CONSTANT C-ENABLED? 0>")

        XCTAssertNoDifference(
            try Game.find("isCEnabled"),
            Statement(
                id: "isCEnabled",
                code: "let isCEnabled = 0",
                type: .integerZero,
                category: .constants,
                isCommittable: true,
                isMutable: false
            )
        )

        XCTAssertNoDifference(
            process("<SETG C-ENABLED? 42>", type: .zCode),
            .statement(
                code: "Globals.isCEnabled.set(to: 42)",
                type: .int
            )
        )

        XCTAssertNoDifference(
            try Game.find("isCEnabled"),
            Statement(
                id: "isCEnabled",
                code: "var isCEnabled = 0",
                type: .int,
                category: .globals,
                isCommittable: true,
                isMutable: true
            )
        )
    }

    func testSetGlobalWithoutAName() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .decimal(3),
            ], with: &localVariables).process()
        )
    }
}
