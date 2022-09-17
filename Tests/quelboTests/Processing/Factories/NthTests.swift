//
//  NthTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class NthTests: QuelboTests {
    let factory = Factories.Nth.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("NTH"))
    }

    func testNthElementInVector() throws {
        let symbol = try factory.init([
            .form([
                .atom("VECTOR"),
                .string("AB"),
                .string("CD"),
                .string("EF")
            ]),
            .decimal(2)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"["AB", "CD", "EF"].nthElement(2)"#,
            type: .string
        ))
    }

    func testShortHandCall() throws {
        let symbol = try Factories.SetVariable.init([
            .atom("A"),
            .form([
                .decimal(3),
                .form([
                    .atom("VECTOR"),
                    .string("AB"),
                    .string("CD"),
                    .string("EF")
                ])
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"a.set(to: ["AB", "CD", "EF"].nthElement(3))"#,
            type: .string
        ))
    }
}
