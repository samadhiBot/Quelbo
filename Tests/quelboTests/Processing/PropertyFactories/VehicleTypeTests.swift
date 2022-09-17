//
//  VehicleTypeTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class VehicleTypeTests: QuelboTests {
    let factory = Factories.VehicleType.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findPropertyFactory("VTYPE"))
    }

    func testVehicleType() throws {
        let symbol = try factory.init([
            .bool(true)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "vehicleType",
            code: "vehicleType: true",
            type: .bool
        ))
    }

    func testVehicleTypeDecimalNonZero() throws {
        let symbol = try factory.init([
            .decimal(1)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "vehicleType",
            code: "vehicleType: true",
            type: .bool
        ))
    }

    func testVehicleTypeDecimalZero() throws {
        let symbol = try factory.init([
            .decimal(0)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "vehicleType",
            code: "vehicleType: false",
            type: .bool
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "vehicleType",
            type: .bool
        ))
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .bool(true),
                .bool(false),
            ], with: &localVariables).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("10")
            ], with: &localVariables).process()
        )
    }
}
