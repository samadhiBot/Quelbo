//
//  PutRestTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PutRestTests: QuelboTests {
    let factory = Factories.PutRest.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("PUTREST"))
    }

    func testPutRest() throws {
        let symbol = try factory.init([
            .list([
                .decimal(1),
                .decimal(2),
                .decimal(3),
                .decimal(4)
            ]),
            .list([
                .decimal(5),
                .decimal(6),
                .decimal(7)
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                [1, 2, 3, 4].putRest([5, 6, 7])
                """,
            type: .int.array
        ))
    }

    func testPutRestDifferentTypes() throws {
        let symbol = try factory.init([
            .list([
                .decimal(1),
                .decimal(2),
                .decimal(3),
                .decimal(4)
            ]),
            .list([
                .character("A"),
                .character("B"),
                .character("C"),
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                [1, 2, 3, 4].putRest(["A", "B", "C"])
                """,
            type: .someTableElement.array
        ))
    }

    func testPutRestMixedTypes() throws {
        let symbol = try factory.init([
            .list([
                .decimal(1),
                .character("A"),
                .decimal(3),
                .character("C"),
            ]),
            .list([
                .decimal(2),
                .character("B"),
                .decimal(4)
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                [1, "A", 3, "C"].putRest([2, "B", 4])
                """,
            type: .someTableElement.array
        ))
    }
}
