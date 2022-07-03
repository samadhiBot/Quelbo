//
//  SubtractTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SubtractTests: QuelboTests {
    let factory = Factories.Subtract.self

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
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("-"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("SUB"))
    }

    func testSubtractOneDecimal() throws {
        let symbol = try factory.init([
            .decimal(42),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "-42",
            type: .int
        ))
    }

    func testSubtractOneAtom() throws {
        registry.append(
            Symbol(id: "foo", type: .int)
        )

        let symbol = try factory.init([
            .local("FOO"),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "-foo",
            type: .int
        ))
    }

    func testSubtractTwoDecimals() throws {
        let symbol = try factory.init([
            .decimal(9),
            .decimal(3),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".subtract(9, 3)",
            type: .int
        ))
    }

    func testSubtractThreeDecimals() throws {
        let symbol = try factory.init([
            .decimal(20),
            .decimal(5),
            .decimal(2),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: ".subtract(20, 5, 2)",
            type: .int
        ))
    }

    func testSubtractTwoAtoms() throws {
        let symbol = try factory.init([
            .atom("BIG-NUMBER"),
            .atom("BIGGER-NUMBER"),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "bigNumber.subtract(biggerNumber)",
            type: .int
        ))
    }

    func testSubtractAtomAndDecimal() throws {
        let symbol = try factory.init([
            .global("CYCLOWRATH"),
            .decimal(1),
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "cyclowrath.subtract(1)",
            type: .int
        ))
    }

    func testSubtractAtomAndFunctionResult() throws {
        let symbol = try factory.init([
            .global("BASE-SCORE"),
            .form([
                .atom("OTVAL-FROB")
            ])
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            code: "baseScore.subtract(otvalFrob())",
            type: .int
        ))
    }
}
