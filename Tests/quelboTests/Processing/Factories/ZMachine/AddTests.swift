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

    override func setUp() {
        super.setUp()

        Game.commit(
            Symbol(id: "baseScore", type: .int, category: .globals),
            Symbol(id: "cyclowrath", type: .int, category: .globals),
            Symbol(id: "myBike", type: .string, category: .globals),
            Symbol(id: "otvalFrob", type: .int, category: .routines)
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("+"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("ADD"))
    }

    func testAddTwoDecimals() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".add(2, 3)",
            type: .int
        ))
    }

    func testAddThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
            .decimal(4),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".add(2, 3, 4)",
            type: .int
        ))
    }

    func testAddTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "bigNumber.add(biggerNumber)",
            type: .int
        ))
    }

    func testAddAtomAndDecimal() throws {
        let symbol = try factory.init([
            .global("CYCLOWRATH"),
            .decimal(1),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "cyclowrath.add(1)",
            type: .int
        ))
    }

    func testAddAtomAndFunctionResult() throws {
        let symbol = try factory.init([
            .global("BASE-SCORE"),
            .form([
                .atom("OTVAL-FROB")
            ])
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "baseScore.add(otvalFrob())",
            type: .int
        ))
    }

    func testAddOneToTableElement() throws {
        registry.append(
            Symbol(id: "src", code: "<table definition>", type: .table)
        )

        let symbol = try factory.init([
            .form([
                .atom("GETB"),
                .local("SRC"),
                .decimal(0)
            ]),
            .decimal(1)
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "try src.get(at: 0).add(1)",
            type: .int
        ))
    }

    func testAddOneToGlobalDefinedAsFalse() throws {
        let pAclause = try Factories.Global([
            .atom("P-ACLAUSE"),
            .bool(false)
        ], with: &registry).process()

        XCTAssertNoDifference(pAclause, Symbol(
            id: "pAclause",
            code: "var pAclause: Bool = false",
            type: .variable(.bool),
            category: .globals,
            meta: [.typeCertainty(.booleanFalse)]
        ))

        let symbol = try factory.init([
            .global("P-ACLAUSE"),
            .decimal(1)
        ], with: &registry).process()

        XCTAssertNoDifference(pAclause, Symbol(
            id: "pAclause",
            code: "var pAclause: Int = 0",
            type: .variable(.int),
            category: .globals,
            meta: []
        ))

        XCTAssertNoDifference(symbol, Symbol(
            code: "pAclause.add(1)",
            type: .int
        ))
    }

    func testAddOneDecimalThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
            ], with: &registry)
        )
    }

    func testAddDecimalAndBoolThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
                .bool(true),
            ], with: &registry)
        )
    }

    func testAddDecimalAndStringThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
                .string("💣"),
            ], with: &registry)
        )
    }

    func testAddDecimalAndStringGlobalThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
                .global("MY-BIKE"),
            ], with: &registry)
        )
    }
}
