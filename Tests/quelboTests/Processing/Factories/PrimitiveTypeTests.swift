//
//  PrimitiveTypeTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 9/10/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PrimitiveTypeTests: QuelboTests {
    let factory = Factories.PrimitiveType.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("PRIMTYPE"))
    }

    func testPrimitiveTypeFalse() throws {
        let symbol = try factory.init([
            .atom("FALSE")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Bool",
            type: .bool
        ))
    }

    func testPrimitiveTypeFix() throws {
        let symbol = try factory.init([
            .atom("FIX")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Int",
            type: .int
        ))
    }

    func testPrimitiveTypeObject() throws {
        let symbol = try factory.init([
            .atom("OBJECT")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Object",
            type: .object
        ))
    }

    func testPrimitiveTypeTable() throws {
        let symbol = try factory.init([
            .atom("TABLE")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Table",
            type: .table
        ))
    }

    func testPrimitiveTypeArray() throws {
        let symbol = try factory.init([
            .atom("VECTOR")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Array",
            type: .unknown.array
        ))
    }

    /*
     <PRIMTYPE !\A>        -->     FIX
     <PRIMTYPE <+1 2>>    -->     FIX
     <PRIMTYPE "ABC">    -->     STRING
     */

    func testPrimitiveTypeCharacter() throws {
        let symbol = process(#"""
            <PRIMTYPE !\A>
        """#)

        XCTAssertNoDifference(symbol, .statement(
            code: "Int",
            type: .int
        ))
    }

    func testPrimitiveTypeAddForm() throws {
        let symbol = process("""
            <PRIMTYPE <+ 1 2>>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: "1.add(2)",
            type: .int
        ))
    }

    func testPrimitiveTypeString() throws {
        let symbol = process("""
            <PRIMTYPE "ABC">
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: "String",
            type: .string
        ))
    }
}
