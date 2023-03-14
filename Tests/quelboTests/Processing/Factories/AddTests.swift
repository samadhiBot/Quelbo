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
            code: ".add(bigNumber, biggerNumber)",
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
        process("""
            <GLOBAL BASE-SCORE 0>

            <OBJECT TROPHY-CASE>

            <ROUTINE OTVAL-FROB ("OPTIONAL" (O ,TROPHY-CASE) "AUX" F (SCORE 0))
                 <SET F <FIRST? .O>>
                 <REPEAT ()
                     <COND (<NOT .F> <RETURN .SCORE>)>
                     <SET SCORE <+ .SCORE <GETP .F ,P?TVALUE>>>
                     <COND (<FIRST? .F> <OTVAL-FROB .F>)>
                     <SET F <NEXT? .F>>>>

        """)

        let symbol = process("<SETG SCORE <+ ,BASE-SCORE <OTVAL-FROB>>>")

        XCTAssertNoDifference(symbol, .statement(
            id: "score",
            code: """
                var score: Int = .add(Global.baseScore, otvalFrob())
                """,
            type: .int,
            category: .globals,
            isCommittable: true,
            returnHandling: .implicit
        ))

        XCTAssertNoDifference(
            Game.findInstance("baseScore"),
            Instance(Statement(
                id: "baseScore",
                code: "var baseScore: Int = 0",
                type: .int,
                category: .globals,
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
            code: ".add(try Global.src.get(at: 0), 1)",
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
            Game.findInstance("pAclause"),
            Instance(processed)
        )

        XCTAssertNoDifference(
            process("<+ P-ACLAUSE 1>"),
            .statement(
                code: ".add(Global.pAclause, 1)",
                type: .int,
                returnHandling: .implicit
            )
        )

        XCTAssertNoDifference(
            Game.findInstance("pAclause"),
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
