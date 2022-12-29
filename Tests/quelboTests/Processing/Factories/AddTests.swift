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
            type: .int,
            returnHandling: .implicit
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
            type: .int,
            returnHandling: .implicit
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
            type: .int,
            returnHandling: .implicit
        ))
    }

    func testAddMutableLocalAndDecimal() throws {
        localVariables.append(.init(id: "count", type: .int, isMutable: true))

        let symbol = try factory.init([
            .local("COUNT"),
            .decimal(1),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".add(count, 1)",
            type: .int,
            returnHandling: .implicit
        ))

        XCTAssertNoDifference(
            findLocalVariable("count"),
            Statement(
                id: "count",
                type: .int,
                isMutable: true
            )
        )
    }

    func testAddDecimalAndLocal() throws {
        localVariables.append(.init(id: "count", type: .int, isMutable: true))

        let symbol = try factory.init([
            .decimal(1),
            .local("COUNT"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".add(1, count)",
            type: .int,
            returnHandling: .implicit
        ))

        XCTAssertNoDifference(
            findLocalVariable("count"),
            Statement(
                id: "count",
                type: .int,
                isMutable: true
            )
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
            .global(.atom("BASE-SCORE")),
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
            type: .int,
            returnHandling: .implicit
        ))

        XCTAssertNoDifference(
            Game.findGlobal("baseScore"),
            Instance(Statement(
                id: "baseScore",
                type: .int,
                isCommittable: true
            ))
        )
    }

    func testAddOneToTableElement() throws {
        try! Game.commit([
            .variable(id: "src", type: .table, category: .globals),
        ])

        let symbol = try factory.init([
            .form([
                .atom("GETB"),
                .global(.atom("SRC")),
                .decimal(0)
            ]),
            .decimal(1)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".add(try src.get(at: 0), 1)",
            type: .int,
            returnHandling: .implicit
        ))
    }

    func testAddOneToGlobalDefinedAsFalse() throws {
        let pAclause = process("<GLOBAL P-ACLAUSE <>>")

        let processed = Statement(
            id: "pAclause",
            code: "var pAclause: Bool = false",
            type: .booleanFalse,
            category: .globals,
            isCommittable: true
        )

        XCTAssertNoDifference(pAclause, .statement(processed))

        XCTAssertNoDifference(
            Game.findGlobal("pAclause"),
            Instance(processed)
        )

        XCTAssertNoDifference(
            process("<+ P-ACLAUSE 1>"),
            .statement(
                code: ".add(pAclause, 1)",
                type: .int,
                returnHandling: .implicit
            )
        )

        XCTAssertNoDifference(
            Game.findGlobal("pAclause"),
            Instance(Statement(
                id: "pAclause",
                code: "var pAclause: Int?",
                type: .int.optional,
                category: .globals,
                isCommittable: true
            ))
        )

        XCTAssertNoDifference(pAclause, .statement(
            id: "pAclause",
            code: "var pAclause: Int?",
            type: .int.optional,
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
            type: .int,
            returnHandling: .implicit
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
                .global(.atom("MY-BIKE")),
            ], with: &localVariables)
        )
    }

    func testEvaluate() throws {
        XCTAssertNoDifference(
            evaluate("<+ 2 3 4>"),
            .literal(9)
        )

        XCTAssertNoDifference(
            process("<PRINTN %<+ 2 3 4>>"),
            .statement(
                code: "output(9)",
                type: .void
            )
        )
    }
}
