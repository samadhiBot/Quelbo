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
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("VTYPE"))
    }

    func testVehicleType() throws {
        let symbol = try factory.init([
            .bool(true)
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "vehicleType",
            code: "vehicleType: true",
            type: .bool
        ))
    }

    func testVehicleTypeDecimalNonZero() throws {
        let symbol = try factory.init([
            .decimal(1)
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "vehicleType",
            code: "vehicleType: true",
            type: .bool
        ))
    }

    func testVehicleTypeDecimalZero() throws {
        let symbol = try factory.init([
            .decimal(0)
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "vehicleType",
            code: "vehicleType: false",
            type: .bool
        ))
    }

    func testEmptyThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ], with: &registry).process()
        )
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .bool(true),
                .bool(false),
            ], with: &registry).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("10")
            ], with: &registry).process()
        )
    }
}
