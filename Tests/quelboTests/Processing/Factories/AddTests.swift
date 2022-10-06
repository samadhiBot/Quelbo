//
//  AddTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class AddTests: QuelboTests {
    let factory = Factories.Add.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("+"))
        AssertSameFactory(factory, Game.findFactory("ADD"))
    }

    func testAddTwoDecimals() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".add(2, 3)",
            type: .int
        ))
    }

    func testAddThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
            .decimal(4),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".add(2, 3, 4)",
            type: .int
        ))
    }

    func testAddTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                .add(
                    bigNumber,
                    biggerNumber
                )
                """,
            type: .int
        ))
    }

    func testAddMutableLocalAndDecimal() throws {
        localVariables.append(Variable(id: "count", type: .int, isMutable: true))

        let symbol = try factory.init([
            .local("COUNT"),
            .decimal(1),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".add(count, 1)",
            type: .int
        ))

        XCTAssertNoDifference(
            findLocalVariable("count"),
            Variable(id: "count", type: .int)
        )
    }

    func testAddDecimalAndLocal() throws {
        localVariables.append(Variable(id: "count", type: .int, isMutable: true))

        let symbol = try factory.init([
            .decimal(1),
            .local("COUNT"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".add(1, count)",
            type: .int
        ))

        XCTAssertNoDifference(
            findLocalVariable("count"),
            Variable(id: "count", type: .int)
        )
    }

    func testAddGlobalAndFunctionResult() throws {
        try! Game.commit([
            .variable(id: "baseScore", type: .int),
            .statement(
                id: "otvalFrob",
                code: "",
                type: .int,
                category: .routines,
                isCommittable: true
            ),
        ])

        let symbol = try factory.init([
            .global("BASE-SCORE"),
            .form([
                .atom("OTVAL-FROB")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                .add(
                    baseScore,
                    otvalFrob()
                )
                """,
            type: .int
        ))

        XCTAssertNoDifference(
            Game.findGlobal("baseScore"),
            Variable(id: "baseScore", type: .int)
        )
    }

    func testAddOneToTableElement() throws {
        try! Game.commit([
            .variable(id: "src", type: .table, category: .globals),
        ])

        let symbol = try factory.init([
            .form([
                .atom("GETB"),
                .global("SRC"),
                .decimal(0)
            ]),
            .decimal(1)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".add(try src.get(at: 0), 1)",
            type: .int
        ))
    }

    func testAddOneToGlobalDefinedAsFalse() throws {
        let pAclause = process("<GLOBAL P-ACLAUSE <>>")

        XCTAssertNoDifference(Game.findGlobal("pAclause"), Variable(
            id: "pAclause",
            type: .booleanFalse,
            category: .globals,
            isMutable: true
        ))

        XCTAssertNoDifference(pAclause, .statement(
            id: "pAclause",
            code: "var pAclause: Bool = false",
            type: .booleanFalse,
            category: .globals,
            isCommittable: true
        ))

        let symbol = try factory.init([
            .global("P-ACLAUSE"),
            .decimal(1)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".add(pAclause, 1)",
            type: .int
        ))

        XCTAssertNoDifference(Game.findGlobal("pAclause"), Variable(
            id: "pAclause",
            type: .int,
            category: .globals,
            isMutable: true
        ))

        XCTAssertNoDifference(pAclause, .statement(
            id: "pAclause",
            code: "var pAclause: Int = 0",
            type: .optional(.int),
            category: .globals,
            isCommittable: true
        ))
    }

    func testAddOneDecimalThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
            ], with: &localVariables)
        )
    }

    func testAddDecimalAndBool() throws {
        let symbol = try factory.init([
            .decimal(1),
            .bool(true),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".add(1, 1)",
            type: .int
        ))
    }

    func testAddDecimalAndStringThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
                .string("💣"),
            ], with: &localVariables)
        )
    }

    func testAddDecimalAndStringGlobalThrows() throws {
        try Factories.Global([
            .atom("MY-BIKE"),
            .string("My bike")
        ], with: &localVariables).process()

        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
                .global("MY-BIKE"),
            ], with: &localVariables)
        )
    }
}
