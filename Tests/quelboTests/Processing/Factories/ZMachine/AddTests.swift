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
        ]).process()

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
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".add(2, 3, 4)",
            type: .int
        ))
    }

    func testAddTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "bigNumber.add(biggerNumber)",
            type: .int
        ))
    }

    func testAddAtomAndDecimal() throws {
        let symbol = try factory.init([
            .global("CYCLOWRATH"),
            .decimal(1),
        ]).process()

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
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "baseScore.add(otvalFrob())",
            type: .int
        ))
    }

    func testAddOneToTableElement() throws {
        let symbol = try factory.init([
            .form([
                .atom("GETB"),
                .local("SRC"),
                .decimal(0)
            ]),
            .decimal(1)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "try src.get(at: 0).add(1)",
            type: .int
        ))
    }

    func testAddOneToGlobalDefinedAsFalse() throws {
        let pAclause = try Factories.Global([
            .atom("P-ACLAUSE"),
            .bool(false)
        ]).process()

        XCTAssertNoDifference(pAclause, Symbol(
            id: "pAclause",
            code: "var pAclause: Bool = false",
            type: .bool,
            category: .globals,
            meta: [.isLiteralBoolean(false), .typeCertainty(.booleanFalse)]
        ))

        let symbol = try factory.init([
            .global("P-ACLAUSE"),
            .decimal(1)
        ]).process()

        XCTAssertNoDifference(pAclause, Symbol(
            id: "pAclause",
            code: "var pAclause: Int = 0",
            type: .int,
            category: .globals,
            meta: [.isLiteralBoolean(false)]
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
            ])
        )
    }

    func testAddDecimalAndBoolThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
                .bool(true),
            ])
        )
    }

    func testAddDecimalAndStringThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
                .string("💣"),
            ])
        )
    }

    func testAddDecimalAndStringGlobalThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(1),
                .global("MY-BIKE"),
            ])
        )
    }
}
