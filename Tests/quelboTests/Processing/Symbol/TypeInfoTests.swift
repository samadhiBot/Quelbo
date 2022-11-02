//
//  TypeInfoTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/20/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class TypeInfoTests: QuelboTests {
    func testEquality() {
        XCTAssertEqual(
            TypeInfo.bool,
            TypeInfo.bool
        )

        XCTAssertEqual(
            TypeInfo.bool.dataType,
            TypeInfo.bool.dataType
        )

        XCTAssertEqual(
            TypeInfo.bool.confidence,
            TypeInfo.bool.confidence
        )

        XCTAssertEqual(
            TypeInfo.bool.confidence,
            TypeInfo.int.confidence
        )
    }

    func testInequality() {
        XCTAssertNotEqual(
            TypeInfo.bool.dataType,
            TypeInfo.int.dataType
        )

        XCTAssertNotEqual(
            TypeInfo.DataType.bool,
            TypeInfo.DataType.int
        )

        XCTAssertNotEqual(
            TypeInfo.bool,
            TypeInfo.int
        )
    }

    func testArrayModifierOnSomeTableElement() {
        XCTAssertNoDifference(
            TypeInfo.someTableElement,
            TypeInfo(
                dataType: nil,
                confidence: .none,
                isArray: nil,
                isOptional: nil,
                isProperty: nil,
                isTableElement: true
            )
        )

        XCTAssertNoDifference(
            TypeInfo.someTableElement.array,
            TypeInfo(
                dataType: nil,
                confidence: .none,
                isArray: true,
                isOptional: nil,
                isProperty: nil,
                isTableElement: true
            )
        )
    }
}
